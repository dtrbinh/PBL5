from datetime import date, datetime

from src.extension import db
from src.pbl5_ma import CheckInSchema, LogSchema
from src.model import Log
from flask import jsonify, request, jsonify
from src.service.check_in_service import find_by_student_id_and_plate_number_service

check_in_schema = CheckInSchema()
log_schema = LogSchema()
logs_schema = LogSchema(many = True)

def get_all_logs_service():
    logs = Log.query.all()
    return logs_schema.dump(logs)

def create_log_service():
    data = request.json

    if (data and ('plate_number' in data) and ('student_id' in data) and ('img_check_out' in data)):
        plate_number = data['plate_number']
        student_id = data['student_id']
        img_check_out = data['img_check_out']
        try: 
            # Tìm ra lần check_in gần nhất mà có student_id = mã sinh viên mới quẹt được,
                #  palte_number = biển số xe vừa quẹt được
            check_in_find = find_by_student_id_and_plate_number_service(student_id, plate_number)

            if check_in_find:
                time_check_out = datetime.now()
                new_log = Log(check_in_find.time_check_in, time_check_out, check_in_find.plate_number, 
                              student_id, check_in_find.img_check_in, img_check_out)
                db.session.add(new_log)
                db.session.commit()

                ## xóa check-in tìm được
                db.session.delete(check_in_find)
                db.session.commit()
                return jsonify({
                    "log": {
                            "id": new_log.id,
                            "time_check_out": new_log.time_check_out,
                            "time_check_in": new_log.time_check_in,
                            "plate_number": new_log.plate_number,
                            "student_id": new_log.student_id,
                            "img_check_in": new_log.img_check_in,
                            "img_check_out": new_log.img_check_out
                    },
                    "message": "Check out success",
                    "status": 1
                }), 201
            else:
                return jsonify(
                    {
                        "message": "Student have not checked in",
                        "status": 0
                    }
                ), 400
            
        except Exception as e:
            db.session.rollback()
            return jsonify({
                "message": "Check out failed",
                "status": 0
            }), 400
    else:
        return jsonify({
                    "message": "Validation request error",
                    "status": 0
                }), 400



