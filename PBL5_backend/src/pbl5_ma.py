from .extension import ma

class StudentSchema(ma.Schema):
    class Meta:
        fields = ('id', 'name', 'class_name', 'faculty')

class CheckInSchema(ma.Schema):
    class Meta:
        fields = ('id', 'student_id', 'number_plate', 'time_check_in', 'img_check_in')

class LogSchema(ma.Schema):
    class Meta:
        fields = ('id', 'time_check_in', 'time_check_out', 'number_plate', 'student_id', 'img_check_in', 'img_check_out')


