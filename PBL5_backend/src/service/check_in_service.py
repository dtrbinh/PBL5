from datetime import datetime
from src.extension import db
from src.pbl5_ma import CheckInSchema
from src.model import CheckIn
from flask import jsonify, request, jsonify

check_in_schema = CheckInSchema()
check_ins_schema = CheckInSchema(many=True)

# get all check in
def get_all_check_ins_service():
    check_ins = CheckIn.query.all()
    return check_ins_schema.dump(check_ins), 200

# create check in
def create_check_in_service():
    data = request.json

    if (data and ('number_plate' in data) and ('student_id' in data) and ('img_check_in' in data)):
        number_plate = data['number_plate']
        student_id = data['student_id']
        img_check_in = data['img_check_in']
        try: 
            time_check_in = datetime.now()
            check_in = CheckIn(number_plate, student_id, time_check_in, img_check_in)
            db.session.add(check_in)
            db.session.commit()
            return jsonify({
                    "data": {
                        "id": check_in.id,
                        "student_id": student_id,
                        "number_plate": number_plate,
                        "time_check_in": time_check_in,
                        "img_check_in": img_check_in
                    },
                    "message": "SUCCESS",
                    "status": 1
                }), 201
        except Exception:
            db.rollback()
            return jsonify({
                    "data": {
                        "id": "undefined",
                        "student_id": "undefined",
                        "number_plate": "undefined",
                        "time_check_in": "undefined",
                        "img_check_in": "undefined"
                    },
                    "message": "FAILED",
                    "status": 0
                }), 400
    else:
        return jsonify({
                    "data": {
                        "id": "undefined",
                        "student_id": "undefined",
                        "number_plate": "undefined",
                        "time_check_in": "undefined",
                        "img_check_in": "undefined"
                    },
                    "message": "Validation request error",
                    "status": 0
                }), 400

# find by student id and plate number service
def find_by_student_id_and_plate_number_service(student_id, number_plate_input):
    check_in_find = db.session.query(CheckIn).filter(CheckIn.student_id == student_id, 
                                                    CheckIn.number_plate == number_plate_input)\
                                                    .order_by(CheckIn.time_check_in.desc())\
                                                    .first()
    return check_in_find

# update check in by id service
def update_check_in_by_id_service(id):
    check_in = CheckIn.query.get(id)
    data = request.json
    if check_in:
        if (data and ('number_plate' in data) and ('student_id' in data) and ('img_check_in' in data)):
            try:
                check_in.number_plate = request.json['number_plate']
                check_in.student_id=request.json['student_id']
                check_in.img_check_in=request.json['img_check_in']
                db.session.commit()
                return check_in_schema.jsonify(check_in), 200
            except Exception:
                db.session.rollback()
                return jsonify({"message": "Can not update check in!"}), 400
        else:
            return jsonify({
                        "message": "Validation request error"
                    }), 400
    else:
        return jsonify({"message": "Check in not found!"}), 404
    
# delete check in by id service
def delete_check_in_by_id_service(id):
    check_in = CheckIn.query.get(id)
    if check_in:
        try:
            db.session.delete(check_in)
            db.session.commit()
            return check_in_schema.jsonify(check_in), 200
        except Exception:
            db.session.rollback()
            return jsonify({"message": "Can not delete check in!"}), 400
    else:
        return jsonify({"message": "Check in not found!"}), 404