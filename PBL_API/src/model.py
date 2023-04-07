from .extension import db

class Students(db.Model):
    id = db.Column(db.String(20), primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    class_name = db.Column(db.String(20), nullable=False)
    faculty = db.Column(db.String(100), nullable=False)

    def __init__(self, name, class_name, faculty):
        self.name = name
        self.class_name = class_name
        self.faculty = faculty

class CheckIns(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    plate_number = db.Column(db.String(20), nullable=False)
    student_id = db.Column(db.String(20), db.ForeignKey("students.id"), nullable = False)
    time_check_in = db.Column(db.DateTime)

    def __init__(self, plate_number, student_id, time_check_in):
        self.plate_number = plate_number
        self.student_id = student_id
        self.time_check_in = time_check_in

class CheckOuts(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    check_in_id = db.Column(db.Integer, db.ForeignKey("check_ins.id"), nullable = False)
    time_check_out = db.Column(db.DateTime)

    def __init__(self, plate_number, check_in_id, time_check_out):
        self.plate_number = plate_number
        self.check_in_id = check_in_id
        self.time_check_out = time_check_out
