import csv
from src.extension import db
from src.pbl5_ma import StudentSchema
from src.model import Student
from flask import jsonify, request
from unidecode import unidecode
from ..util.upload.uploadImageUtil import uploadImage
import numpy as np
import cv2
from pyzbar import pyzbar

student_schema = StudentSchema()
student_schemas = StudentSchema(many=True)

# get all student service
def get_all_students_service():
    students = Student.query.all()
    return student_schemas.dump(students), 200

# add new student
def create_student_service():
    data = request.json

    # validate form data send to server
    if (data and ('id' in data) and ('name' in data) and ('class_name' in data) and ('faculty' in data)):
        try:
            id = request.json['id']
            name = request.json['name']
            class_name = request.json['class_name']
            faculty = request.json['faculty']
            student = Student(id, name, class_name, faculty)
            db.session.add(student)
            db.session.commit()
        except Exception as e:
            print(e)
            db.session.rollback()
            return jsonify({
                "message": "Can not add new student",
                "status": 0
            }), 400
        return student_schema.jsonify(student), 201
    else:
        return jsonify({
            "message": "Validation request error",
            "status": 0
        }), 400

# add new many student
def create_many_students_service():
    data = request.json

    if isinstance(data, list):
        students = []
        for student_data in data:

            # validate form data
            if ('id' in student_data) and ('name' in student_data) and ('class_name' in student_data) and (
                    'faculty' in student_data):
                id = student_data['id']
                name = student_data['name']
                class_name = student_data['class_name']
                faculty = student_data['faculty']
                student = Student(id=id, name=name, class_name=class_name, faculty=faculty)
                students.append(student)
            else:
                return jsonify({
                    "message": "Validation request error",
                    "status": 0
                }), 400
        try:
            db.session.bulk_save_objects(students)
            db.session.commit()
        except Exception as e:
            print(e)
            db.session.rollback()
            return jsonify({"message": "Can not add new students", "status": 0}), 400
        return student_schemas.jsonify(students), 201
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

        # validate form data send to server
        if (data and ('name' in data) and ('class_name' in data) and ('faculty' in data)):
            try:
                student.name = request.json['name']
                student.class_name = request.json['class_name']
                student.faculty = request.json['faculty']
                db.session.commit()
            except Exception as e:
                print(e)
                db.session.rollback()
                return jsonify({"message": "Can not update student!"}), 400
            return student_schema.jsonify(student), 200
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
        except Exception as e:
            print(e)
            db.session.rollback()
            return jsonify({"message": "Can not delete student!"}), 400
        return student_schema.jsonify(student), 200
    else:
        return jsonify({"message": "Student not found!"}), 404

# scan student card service
def scan_student_card_service():

    # validate request
    if 'student_card_img' in request.files:
        student_card_image = request.files['student_card_img']

        # # Tạo đường dẫn ảnh tạm
        # prefix = f'SWM-{randint(10, 900)}-{date.today()}'
        # filename = secure_filename(student_card_image.filename)
        # filename = f'{prefix}-{filename}'
        # filename = 'src/static/upload/image/student-cards/' + filename
        # student_card_image.save(filename)
        # Get image path
        img_path = uploadImage(student_card_image, 'student-cards')
         # Đọc mã số sv từ barcode
        try:
            image = cv2.imread(img_path)
            barcodes = pyzbar.decode(image)
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
                print(student_id)
                student = Student.query.get(student_id)
                if student:
                    if 'arduino' in request.form and request.form['arduino'] == "1":
                        student.name = unidecode(student.name).replace(" ", "")
                        student.faculty = unidecode(student.faculty).replace(" ", "")
                    return jsonify({
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
    
def import_file_students_service():
    if 'file_students' not in request.files:
        return jsonify({"message": "No file provided", "status": 0}), 400

    file = request.files['file_students']

    if file.filename == '':
        return jsonify({"message": "No file selected", "status": 0}), 400

    students = []
    try:
        # Đọc dữ liệu từ file CSV
        reader = csv.DictReader(file.stream.read().decode("utf-8-sig").splitlines())

        for row in reader:
            student = Student(
                id=row['mssv'],
                name=row['name'],
                class_name=row['class_name'],
                faculty=row['faculty']
            )
            students.append(student)
        
    except csv.Error as e:
        return jsonify({"message": "Error reading CSV file", "status": 0}), 400

    try:
        db.session.bulk_save_objects(students)
        db.session.commit()
    except Exception as e:
        print(e)
        db.session.rollback()
        return jsonify({"message": "Error saving students to database", "status": 0}), 400

    return student_schemas.jsonify(students), 201