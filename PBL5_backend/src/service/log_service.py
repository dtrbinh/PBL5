from datetime import date, datetime

from src.extension import db
from src.pbl5_ma import CheckInSchema, LogSchema
from src.model import Log
from flask import jsonify, request, jsonify
from src.service.check_in_service import find_by_student_id_and_plate_number_service

check_in_schema = CheckInSchema()
log_schema = LogSchema()
logs_schema = LogSchema(many = True)

# get all log service
def get_all_logs_service():
    logs = Log.query.all()
    return logs_schema.dump(logs), 200

# create log service
def create_log_service():
    data = request.json

    if (data and ('number_plate' in data) and ('student_id' in data) and ('img_check_out' in data)):
        number_plate = data['number_plate']
        student_id = data['student_id']
        img_check_out = data['img_check_out']
        try: 
            # Tìm ra lần check_in gần nhất mà có student_id = mã sinh viên mới quẹt được,
                #  palte_number = biển số xe vừa quẹt được
            check_in_find = find_by_student_id_and_plate_number_service(student_id, number_plate)

            if check_in_find:
                time_check_out = datetime.now()
                new_log = Log(check_in_find.time_check_in, time_check_out, number_plate, 
                              student_id, check_in_find.img_check_in, img_check_out)
                db.session.add(new_log)
                db.session.commit()

                ## xóa check-in tìm được
                db.session.delete(check_in_find)
                db.session.commit()
                return jsonify({
                    "data": {
                            "id": new_log.id,
                            "time_check_out": new_log.time_check_out,
                            "time_check_in": new_log.time_check_in,
                            "number_plate": new_log.number_plate,
                            "student_id": new_log.student_id,
                            "img_check_in": new_log.img_check_in,
                            "img_check_out": new_log.img_check_out
                    },
                    "message": "SUCCESS",
                    "status": 1
                }), 201
            else:
                return jsonify({
                    "data": {
                        "id": "undefined",
                        "time_check_out": "undefined",
                        "time_check_in": "undefined",
                        "number_plate": "undefined",
                        "student_id": "undefined",
                        "img_check_in": "undefined",
                        "img_check_out": "undefined"
                    },
                    "message": "Student have not checked in",
                    "status": 0
                }), 400
            
        except Exception as e:
            db.session.rollback()
            return jsonify({
                "data": {
                    "id": "undefined",
                    "time_check_out": "undefined",
                    "time_check_in": "undefined",
                    "number_plate": "undefined",
                    "student_id": "undefined",
                    "img_check_in": "undefined",
                    "img_check_out": "undefined"
                },
                "message": "FAILED",
                "status": 0
            }), 400
    else:
        return jsonify({
                    "data": {
                        "id": "undefined",
                        "time_check_out": "undefined",
                        "time_check_in": "undefined",
                        "number_plate": "undefined",
                        "student_id": "undefined",
                        "img_check_in": "undefined",
                        "img_check_out": "undefined"
                    },
                    "message": "Validation request error",
                    "status": 0
                }), 400

# update log by id service
def update_log_by_id_service(id):
    log = Log.query.get(id)
    data = request.json
    if log:
        if (data and ('number_plate' in data) and ('student_id' in data) and ('img_check_out' in data) \
            and ('img_check_in' in data) and ('time_check_in' in data) and ('time_check_out' in data)):
            try:
                log.img_check_in = data['img_check_in']
                log.img_check_out = data['img_check_out']
                log.number_plate = data['number_plate']
                log.student_id = data['student_id']
                log.time_check_in = datetime.fromisoformat(data['time_check_in'])
                log.time_check_out = datetime.fromisoformat(data['time_check_out'])
                db.session.commit()
                return log_schema.jsonify(log), 200
            except Exception as e:
                db.session.rollback()
                return jsonify({"message": "Can not update log!"}), 400
        else:
            return jsonify({
                        "message": "Validation request error"
                    }), 400
    else:
        return jsonify({"message": "Log not found!"}), 404
    
# delete log by id service
def delete_log_by_id_service(id):
    log = Log.query.get(id)
    if log:
        try:
            db.session.delete(log)
            db.session.commit()
            return log_schema.jsonify(log), 200
        except Exception:
            db.session.rollback()
            return jsonify({"message": "Can not delete log!"}), 400
    else:
        return jsonify({"message": "Log not found!"}), 404

# find log by id service
def find_log_by_id_service(id):
    log = Log.query.get(id)
    if log:
        return log.jsonify(log)
    else:
        return jsonify({"message": "Log not found!"}), 404