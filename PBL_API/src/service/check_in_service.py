from datetime import date, datetime
import os
from random import randint
from util.model import getPlateTextFromImage
from src.extension import db
from src.pbl5_ma import CheckInSchema
from src.model import CheckIn
from flask import jsonify, request, jsonify
from pyzbar import pyzbar

from src.service.student_service import find_student_by_id_service

from werkzeug.utils import secure_filename

import numpy as np
import cv2

check_in_schema = CheckInSchema()
check_ins_schema = CheckInSchema(many=True)

def get_all_check_ins_service():
    check_ins = CheckIn.query.all()
    return check_ins_schema.dump(check_ins)

def create_check_in_service():
    if (('student_card_img' in request.files) and ('plate_img' in request.files)):
        student_card_image = request.files['student_card_img']
        plate_image = request.files['plate_img']
        # Đọc mã số sv từ barcode
        img = cv2.imdecode(np.frombuffer(student_card_image.read(), np.uint8), cv2.IMREAD_COLOR)
        barcodes = pyzbar.decode(img)

        # Tạo đường dẫn ảnh tạm
        prefix = f'SWM-{randint(10,900)}-{date.today()}'

        # nếu có file ảnh
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
            plate_number = getPlateTextFromImage(imgPath)

            # nếu có plate_number
            if plate_number is None:
                return jsonify(
                    {
                        "message": "Can not get plate text number",
                        "status": 0
                    }
                ), 400
            elif len(barcodes) <= 0:
                return jsonify(
                    {
                        "message": "Can not get student id in student card",
                        "status": 0
                    }
                ), 400
            else:
                barcode_data = barcodes[0].data.decode('utf-8')
                student_id = barcode_data

                student = find_student_by_id_service(student_id)
                print(student)

                if student: 
                    time_check_in = datetime.now()
                    check_in = CheckIn(plate_number, student_id, time_check_in)
                    db.session.add(check_in)
                    db.session.commit()
                    return jsonify({
                        "data": {
                            "check_in": {
                                "id": check_in.id,
                                "student_id": student_id,
                                "plate_number": plate_number,
                                "time_check_in": time_check_in,
                            },
                            "message": "Check in success"
                        },
                        "status": 1
                    }), 201
                else:
                    return jsonify(
                        {
                            "message": "Student is not exist in system",
                            "status": 0
                        }
                    ), 400
        except Exception as e:
            db.session.rollback()
            return jsonify({
                "message": "Check in failed",
                "status": 0
            }), 400
    else:
        return jsonify({
                "message": "Validation request error",
                "status": 0
            }), 400
    
def find_by_student_id_and_plate_number_service(student_id, plate_number_input):
    check_in_find = db.session.query(CheckIn).filter(CheckIn.student_id == student_id, 
                                                    CheckIn.plate_number == plate_number_input)\
                                                    .order_by(CheckIn.time_check_in.desc())\
                                                    .first()
    return check_in_find
