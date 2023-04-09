# PBL5
# Cài thư viện: pip install -r requirements.txt
# chạy: python main.py

# API check-in: /check-ins
METHOD: POST
FORM-DATA: student_card_img và plate_img

# API check-out: /check-outs
METHOD: POST

FORM-DATA: student_card_img và plate_img

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
