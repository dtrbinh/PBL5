from flask import Blueprint
from src.service.student_service import get_all_students_service,\
    create_student_service, scan_student_card_service, find_student_by_id_service, \
    update_student_by_id_service, delete_student_by_id_service, create_students_service

students = Blueprint('students', __name__, url_prefix='/students')

# Get all student
@students.route('', methods=['GET'])
def get_all_students():
    return get_all_students_service()

# Find student by id
@students.route("/<string:id>", methods=['GET'])
def find_student_by_id(id):
    return find_student_by_id_service(id)

# Scan card
@students.route('/scan-card', methods=['POST'])
def scan_student_card():
    return scan_student_card_service()

# Add new student
@students.route('', methods=['POST'])
def create_student():
    return create_student_service()

# Add new many students
@students.route('/insertMany', methods=['POST'])
def create_students():
    return create_students_service()

# update student
@students.route("/<string:id>", methods=['PUT'])
def update_student_by_id(id):
    return update_student_by_id_service(id)

# delete student
@students.route("/<string:id>", methods=['DELETE'])
def delete_student_by_id(id):
    return delete_student_by_id_service(id)

