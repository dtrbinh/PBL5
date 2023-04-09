from src.extension import db
from src.pbl5_ma import StudentSchema
from src.model import Student
from flask import request

student_schema = StudentSchema()
student_schemas = StudentSchema(many=True)

def get_all_students_service():
    students = Student.query.all()
    print(students)
    return student_schemas.dump(students)

def create_student_service():
    id= request.json['id']
    name = request.json['name']
    class_name=request.json['class_name']
    faculty=request.json['faculty']
    student = Student(id, name, class_name, faculty)
    db.session.add(student)
    db.session.commit()
    return student_schema.jsonify(student)

def find_student_by_id_service(id):
    student = db.session.query(Student).filter(Student.id == id)
    return student
