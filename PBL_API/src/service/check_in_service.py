from datetime import datetime
from src.extension import db
from src.pbl5_ma import CheckInSchema
from src.model import CheckIn
from flask import jsonify, request, jsonify

check_in_schema = CheckInSchema()
check_ins_schema = CheckInSchema(many=True)

def get_all_check_ins_service():
    check_ins = CheckIn.query.all()
    return check_ins_schema.dump(check_ins)

def create_check_in_service():
    data = request.json

    if (data and ('plate_number' in data) and ('student_id' in data) and ('img_check_in' in data)):
        plate_number = data['plate_number']
        student_id = data['student_id']
        img_check_in = data['img_check_in']
        try: 
            time_check_in = datetime.now()
            check_in = CheckIn(plate_number, student_id, time_check_in, img_check_in)
            db.session.add(check_in)
            db.session.commit()
            return jsonify({
                    "check_in": {
                        "id": check_in.id,
                        "student_id": student_id,
                        "plate_number": plate_number,
                        "time_check_in": time_check_in,
                        "img_check_in": img_check_in
                    },
                    "message": "Check in success",
                    "status": 1
                }), 201
        except Exception:
            db.rollback()
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
