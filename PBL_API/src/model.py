from sqlalchemy import create_engine
from .extension import db
engine = create_engine('sqlite:///database.db')

class Student(db.Model):
    id = db.Column(db.String(20), primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    class_name = db.Column(db.String(20), nullable=False)
    faculty = db.Column(db.String(100), nullable=False)

    def __init__(self, id, name, class_name, faculty):
        self.id = id
        self.name = name
        self.class_name = class_name
        self.faculty = faculty

class CheckIn(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    plate_number = db.Column(db.String(20), nullable=False)
    student_id = db.Column(db.String(20), db.ForeignKey("student.id"), nullable = False)
    time_check_in = db.Column(db.DateTime)
    img_check_in = db.Column(db.String(255), nullable = False)
    def __init__(self, plate_number, student_id, time_check_in, img_check_in):
        self.plate_number = plate_number
        self.student_id = student_id
        self.time_check_in = time_check_in
        self.img_check_in = img_check_in

class Log(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    plate_number = db.Column(db.String(20), nullable=False)
    student_id = db.Column(db.String(20), db.ForeignKey("student.id"), nullable = False)
    time_check_in = db.Column(db.DateTime)
    time_check_out = db.Column(db.DateTime)
    img_check_in = db.Column(db.String(255), nullable = False)
    img_check_out = db.Column(db.String(255), nullable = False)

    def __init__(self, time_check_in, time_check_out, plate_number, student_id, img_check_in, img_check_out):
        self.time_check_in = time_check_in
        self.time_check_out = time_check_out
        self.plate_number = plate_number
        self.student_id = student_id
        self.img_check_in = img_check_in
        self.img_check_out = img_check_out