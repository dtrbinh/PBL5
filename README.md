# PBL5
# Cài thư viện: pip install -r requirements.txt
# chạy: python main.py

# API check-in: /check-ins
METHOD: POST
BODY: plate_number, student_id, img_check_in

# API check-out: /check-outs
METHOD: POST

BODY: plate_number, student_id, img_check_out

# API lấy tất cả lịch sử ra vào: /logs
METHOD: GET

# API lấy tất cả học sinh: /students
METHOD: GET

# API thêm mới học sinh: /students
METHOD: POST
Body:
    {
        "id",
        "name",
        "class_name",
        "faculty",
    }
