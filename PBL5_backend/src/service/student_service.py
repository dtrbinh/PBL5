from src.extension import db
from src.pbl5_ma import StudentSchema
from src.model import Student
from flask import jsonify, request

student_schema = StudentSchema()
student_schemas = StudentSchema(many=True)

import numpy as np
import cv2
from pyzbar import pyzbar

def get_all_students_service():
    students = Student.query.all()
    return student_schemas.dump(students)

def create_student_service():
    data = request.json

    if (data and ('id' in data) and ('name' in data) and ('class_name' in data) and ('faculty' in data)):
        try:
            id= request.json['id']
            name = request.json['name']
            class_name=request.json['class_name']
            faculty=request.json['faculty']
            student = Student(id, name, class_name, faculty)
            db.session.add(student)
            db.session.commit()
            return student_schema.jsonify(student)
        except Exception:
            db.rollback()
            return jsonify({
                "message": "Can not add new student",
                "status": 0
            }), 400
    else:
        return jsonify({
                "message": "Validation request error",
                "status": 0
            }), 400

def find_student_by_id_service(id):
    student = db.session.query(Student).filter(Student.id == id).first()
    return student

def scan_student_card_service():
    if (('student_card_img' in request.files)):
        student_card_image = request.files['student_card_img']
         # Đọc mã số sv từ barcode
        img = cv2.imdecode(np.frombuffer(student_card_image.read(), np.uint8), cv2.IMREAD_COLOR)
        barcodes = pyzbar.decode(img)
        if len(barcodes) <= 0:
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
            if student:
                return jsonify ({
                    "student": {
                        "student_id": student.id,
                        "name": student.name,
                        "class_name": student.class_name,
                        "faculty": student.faculty
                    },
                    "status": 1,
                    "message": "SUCCESS"
                }), 200
            else:
                return jsonify({
                    "message": "Student not found",
                    "status": 0
                }), 404
    else: 
        return jsonify({
                "message": "Validation request error",
                "status": 0
            }), 400