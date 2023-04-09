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

-- Thành công:
![image](https://user-images.githubusercontent.com/93651748/230786575-af3bf709-87ca-4cc2-854e-84db7bb6c6d7.png)

-- CHưa check in:

![image](https://user-images.githubusercontent.com/93651748/230786609-320e73c9-6fa9-4230-beb9-be840f868979.png)


-- Checkout thất bại:

![image](https://user-images.githubusercontent.com/93651748/230786637-0a62c5cc-e67a-4e17-ac98-899ce3402b66.png)


-- Các trường hợp lỗi về thiếu tham số trong form - data, lấy text, mã sv không được thì giống như check-in

# API lấy tất cả lịch sử ra vào: /logs
METHOD: GET

![image](https://user-images.githubusercontent.com/93651748/230786710-e6102983-c9a5-4149-bdc4-5086386b189e.png)


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
 ![image](https://user-images.githubusercontent.com/93651748/230786762-455129d9-58da-446d-b8b3-c0e1d50de1a8.png)

