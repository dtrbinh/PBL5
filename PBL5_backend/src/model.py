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
    
    def __str__(self):
        return f"Student {{\n" \
               f"  id: {self.id}\n" \
               f"  name: {self.name}\n" \
               f"  class_name: {self.class_name}\n" \
               f"  faculty: {self.faculty}\n" \
               f"}}"

class CheckIn(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    number_plate = db.Column(db.String(20), unique=True, nullable=False)
    student_id = db.Column(db.String(20), db.ForeignKey("student.id"), nullable = False)
    time_check_in = db.Column(db.DateTime)
    img_check_in = db.Column(db.String(255), nullable = False)
    def __init__(self, number_plate, student_id, time_check_in, img_check_in):
        self.number_plate = number_plate
        self.student_id = student_id
        self.time_check_in = time_check_in
        self.img_check_in = img_check_in
    
    def __str__(self):
        return f"CheckIn {{\n" \
               f"  id: {self.id}\n" \
               f"  number_plate: {self.number_plate}\n" \
               f"  student_id: {self.student_id}\n" \
               f"  time_check_in: {self.time_check_in}\n" \
               f"  img_check_in: {self.img_check_in}\n" \
               f"}}"

class Log(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    number_plate = db.Column(db.String(20), nullable=False)
    student_id = db.Column(db.String(20), db.ForeignKey("student.id"), nullable = False)
    time_check_in = db.Column(db.DateTime)
    time_check_out = db.Column(db.DateTime)
    img_check_in = db.Column(db.String(255), nullable = False)
    img_check_out = db.Column(db.String(255), nullable = False)

    def __init__(self, time_check_in, time_check_out, number_plate, student_id, img_check_in, img_check_out):
        self.time_check_in = time_check_in
        self.time_check_out = time_check_out
        self.number_plate = number_plate
        self.student_id = student_id
        self.img_check_in = img_check_in
        self.img_check_out = img_check_out

    def __str__(self):
        return f"Log {{\n" \
               f"  id: {self.id}\n" \
               f"  number_plate: {self.number_plate}\n" \
               f"  student_id: {self.student_id}\n" \
               f"  time_check_in: {self.time_check_in}\n" \
               f"  time_check_out: {self.time_check_out}\n" \
               f"  img_check_in: {self.img_check_in}\n" \
               f"  img_check_out: {self.img_check_out}\n" \
               f"}}"