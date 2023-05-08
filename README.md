# PBL5
# Cài thư viện: pip install -r requirements.txt
# chạy: python app.py

# API quét mã barcode thẻ SV: /students/scan-card
METHOD: POST
FORM_DATA: student_card_img

![image](https://user-images.githubusercontent.com/93651748/232287571-49f0025a-1ba3-4334-a4f9-5354b2afea03.png)


# API đọc biển số xe: /plates/read-plate-text
METHOD POST
FORM_DATA: plate_img

![image](https://user-images.githubusercontent.com/93651748/232288098-6901e7e8-6eec-4e7c-b46e-7589c816f704.png)


# API check-in: /check-ins
METHOD: POST
BODY: plate_number, student_id, img_check_in

-- Form data thiếu tham số:
![image](https://user-images.githubusercontent.com/93651748/230785693-17bfb386-ad1c-4d99-96f2-14ac01679912.png)

-- Thành công:
![image](https://user-images.githubusercontent.com/93651748/232286912-74b3380f-6908-40c0-b561-2c2264941fe3.png)


# API check-out: /check-outs
METHOD: POST

BODY: plate_number, student_id, img_check_out

-- Form data thiếu tham số:
![image](https://user-images.githubusercontent.com/93651748/230785693-17bfb386-ad1c-4d99-96f2-14ac01679912.png)

-- Thành công:
![image](https://user-images.githubusercontent.com/93651748/232287137-af1a1c76-ae04-47bd-82f3-b048c9df39ab.png)

-- CHưa check in:

![image](https://user-images.githubusercontent.com/93651748/230786609-320e73c9-6fa9-4230-beb9-be840f868979.png)

-- Checkout thất bại:

![image](https://user-images.githubusercontent.com/93651748/230786637-0a62c5cc-e67a-4e17-ac98-899ce3402b66.png)


# API lấy tất cả lịch sử ra vào: /logs
METHOD: GET

![image](https://user-images.githubusercontent.com/93651748/232287361-52ea8ad1-551a-4f97-aa49-1a1816531e56.png)


# API lấy tất cả học sinh: /students
METHOD: GET

![image](https://user-images.githubusercontent.com/93651748/230786720-659d2726-3207-495e-a9ac-a1726938d42e.png)


# API thêm mới học sinh: /students
METHOD: POST
Body:
    {
        "id",
        "name",
        "class_name",
        "faculty",
    }
    
 -- Thành công:
![image](https://user-images.githubusercontent.com/93651748/232287415-46a76a02-b058-44c0-b41d-b16f95989264.png)


