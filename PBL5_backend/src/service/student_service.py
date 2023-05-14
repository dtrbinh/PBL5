from src.extension import db
from src.pbl5_ma import StudentSchema
from src.model import Student
from flask import jsonify, request
from unidecode import unidecode

student_schema = StudentSchema()
student_schemas = StudentSchema(many=True)

import numpy as np
import cv2
from pyzbar import pyzbar

# get all student service 
def get_all_students_service():
    students = Student.query.all()
    return student_schemas.dump(students), 200

# add new student
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
            return student_schema.jsonify(student), 201
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

# add new many student
def create_students_service():
    data = request.json
    
    if isinstance(data, list):
        students = []
        for student_data in data:
            if ('id' in student_data) and ('name' in student_data) and ('class_name' in student_data) and ('faculty' in student_data):
                try:
                    id = student_data['id']
                    name = student_data['name']
                    class_name = student_data['class_name']
                    faculty = student_data['faculty']
                    student = Student(id=id, name=name, class_name=class_name, faculty=faculty)
                    db.session.add(student)
                    students.append(student)
                except Exception:
                    db.rollback()
                    return jsonify({
                        "message": "Can not add new students",
                        "status": 0
                    }), 400
            else:
                return jsonify({
                        "message": "Validation request error",
                        "status": 0
                    }), 400
        
        db.session.commit()
        return student_schema.jsonify(students, many=True), 201
    else:
        return jsonify({
            "message": "Invalid request data",
            "status": 0
        }), 400

# find student by id service
def find_student_by_id_service(id):
    student = Student.query.get(id)
    if student:
        return student_schema.jsonify(student)
    else:
        return jsonify({"message": "Student not found!"}), 404
    
# update student by id service
def update_student_by_id_service(id):
    student = Student.query.get(id)
    data = request.json
    if student:
        if (data and ('name' in data) and ('class_name' in data) and ('faculty' in data)):
            try:
                student.name = request.json['name']
                student.class_name=request.json['class_name']
                student.faculty=request.json['faculty']
                db.session.commit()
                return student_schema.jsonify(student), 200
            except Exception:
                db.session.rollback()
                return jsonify({"message": "Can not update student!"}), 400
        else:
            return jsonify({
                        "message": "Validation request error",
                        "status": 0
                    }), 400
    else:
        return jsonify({"message": "Student not found!"}), 404

# delete student by id service
def delete_student_by_id_service(id):
    student = Student.query.get(id)
    if student:
        try:
            db.session.delete(student)
            db.session.commit()
            return student_schema.jsonify(student), 200
        except Exception:
            db.session.rollback()
            return jsonify({"message": "Can not delete student!"}), 400
    else:
        return jsonify({"message": "Student not found!"}), 404

# scan student card service
def scan_student_card_service():
    if (('student_card_img' in request.files)):
        student_card_image = request.files['student_card_img']
         # Đọc mã số sv từ barcode
        try:
            img = cv2.imdecode(np.frombuffer(student_card_image.read(), np.uint8), cv2.IMREAD_COLOR)
            barcodes = pyzbar.decode(img)
            if len(barcodes) <= 0:
                return jsonify({
                            "data": {
                                "student_id": 'undefined',
                                "name": 'undefined',
                                "class_name": 'undefined',
                                "faculty": 'undefined'
                            },
                            "status": 0,
                            "message": "Can not get student id in student card",
                        }), 400
            else:
                barcode_data = barcodes[0].data.decode('utf-8')
                student_id = barcode_data
                student = Student.query.get(student_id)
                if student:
                    if 'arduino' in request.form and request.form['arduino'] == "1":
                        student.name = unidecode(student.name).replace(" ", "")
                    return jsonify ({
                        "data": {
                            "student_id": student.id,
                            "name": student.name,
                            "class_name": student.class_name,
                            "faculty": student.faculty
                        },
                        "status": 1,
                        "message": "SUCCESS"
                    }), 201
                else:
                    return jsonify({
                        "data": {
                            "student_id": 'undefined',
                            "name": 'undefined',
                            "class_name": 'undefined',
                            "faculty": 'undefined'
                        },
                        "status": 0,
                        "message": "Student have not in database"
                    }), 404
        except Exception as e:
            print(e)
            return jsonify({
                "data": {
                        "student_id": 'undefined',
                        "name": 'undefined',
                        "class_name": 'undefined',
                        "faculty": 'undefined'
                },
                "status": 0,
                "message": "FAILED"
            }), 400
    else: 
        return jsonify({
                "data": {
                        "student_id": 'undefined',
                        "name": 'undefined',
                        "class_name": 'undefined',
                        "faculty": 'undefined'
                },
                "status": 0,
                "message": "Validation request error"
            }), 400