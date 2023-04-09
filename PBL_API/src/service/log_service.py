from datetime import date, datetime
import os
from random import randint

import cv2
import numpy as np
from util.model import getPlateTextFromImage
from src.extension import db
from src.pbl5_ma import CheckInSchema, LogSchema
from src.model import Log
from flask import jsonify, request, jsonify
from pyzbar import pyzbar
from werkzeug.utils import secure_filename
from src.service.check_in_service import find_by_student_id_and_plate_number_service

check_in_schema = CheckInSchema()
log_schema = LogSchema()
logs_schema = LogSchema(many = True)

def get_all_logs_service():
    logs = Log.query.all()
    return logs_schema.dump(logs)

def create_log_service():
    if (('student_card_img' in request.files) and ('plate_img' in request.files)):
        student_card_image = request.files['student_card_img']
        plate_image = request.files['plate_img']
        img = cv2.imdecode(np.frombuffer(student_card_image.read(), np.uint8), cv2.IMREAD_COLOR)

        # đọc mã bar code
        barcodes = pyzbar.decode(img)

        # tên file lưu tạm ảnh
        prefix = f'SWM-{randint(10,900)}-{date.today()}'
        if plate_image.filename != '':
            filename = secure_filename(plate_image.filename)
            filename = f'{prefix}-{filename}'
            plate_image.save(os.path.join(
                'static/',
                filename
            ))

        try:
            imgPath = f'./static/{filename}'

            # lấy text trên biển số xe
            plate_number_input = getPlateTextFromImage(imgPath)

            # nếu có plate_number
            if plate_number_input is None:
                 return jsonify({
                    "message": "Can not get plate text number",
                    "status": 0
                }), 400
            elif len(barcodes) <= 0:
                return jsonify({
                    "message": "Can not get student id in student card",
                    "status": 0
                }), 400
            else:

                # get text by barcode
                barcode_data = barcodes[0].data.decode('utf-8')
                student_id = barcode_data

                # Tìm ra lần check_in gần nhất mà có student_id = mã sinh viên mới quẹt được,
                #  palte_number = biển số xe vừa quẹt được
                check_in_find = find_by_student_id_and_plate_number_service(student_id, plate_number_input)
                time_check_out = datetime.now()

                # nếu tìm ra được lần check_in
                if check_in_find:
                    new_log = Log(check_in_find.time_check_in, time_check_out, check_in_find.plate_number, student_id)
                    db.session.add(new_log)
                    db.session.commit()

                    ## xóa check-in tìm được
                    db.session.delete(check_in_find)
                    db.session.commit()
                    return jsonify({
                        "data": {
                            "log": {
                                "id": new_log.id,
                                "time_check_out": new_log.time_check_out,
                                "time_check_in": new_log.time_check_in,
                                "plate_number": new_log.plate_number,
                                "student_id": new_log.student_id
                            },
                        "message": "Check out success"
                        },
                        "status": 1
                    }), 201
                else:
                    return jsonify({
                        "message": "Student have not checked in",
                        "status": 0
                    }), 400
        except Exception as e:
            db.session.rollback()
            print(e)
            return jsonify({
                "message": "Check out failed",
                "status": 0
            }), 400
    else:
        return jsonify({
                "message": "Validation request error",
                "status": 0
            }), 400



