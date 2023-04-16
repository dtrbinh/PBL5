from flask import Blueprint
from src.service.student_service import get_all_students_service, create_student_service, scan_student_card_service
students = Blueprint('students', __name__, url_prefix='/students')

@students.route('/', methods=['GET'])
def get_all_students():
    return get_all_students_service(), 200

@students.route('/', methods=['POST'])
def create():
    return create_student_service(), 201

@students.route('/scan-card', methods=['POST'])
def scan_student_card():
    return scan_student_card_service()
