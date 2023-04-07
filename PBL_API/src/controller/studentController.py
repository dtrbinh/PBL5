from flask import Blueprint

students = Blueprint('students', __name__)
@students.route('/get-all-students')
def get_all_students():
    return 'All students'