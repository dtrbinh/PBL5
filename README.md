# PBL5
# Cài thư viện: pip install -r requirements.txt
# chạy: python main.py

# API check-in: /check-ins
METHOD: POST
FORM-DATA: student_card_img và plate_img

-- Form data thiếu tham số:
![image](https://user-images.githubusercontent.com/93651748/230785693-17bfb386-ad1c-4d99-96f2-14ac01679912.png)

-- ĐỌc plate text lỗi:

![image](https://user-images.githubusercontent.com/93651748/230785747-5f093ee8-21dc-4f6b-b66d-791c50f25fb1.png)

-- ĐỌc mã số SV lỗi:
![image](https://user-images.githubusercontent.com/93651748/230785774-e8574bd2-fadd-407c-83de-334610f00dc0.png)

-- Mã số sinh viên không có trong db
![image](https://user-images.githubusercontent.com/93651748/230786439-29cc3863-a594-4d50-ac18-daac37c957c7.png)

-- Thành công:

![image](https://user-images.githubusercontent.com/93651748/230786465-7a859406-0a9d-4637-8c5a-8106b2d354d2.png)



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
