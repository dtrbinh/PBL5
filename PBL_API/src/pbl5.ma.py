from .extension import ma

class StudentSchema(ma.Schema):
    class Meta:
        fields = ('id', 'name', 'class_name', 'faculty')

class CheckInSchema(ma.Schema):
    class Meta:
        fields = ('id', 'student_id', 'time_check_in')

class CheckOutSchema(ma.Schema):
    class Meta:
        fields = ('id', 'check_in_id', 'time_check_out')

