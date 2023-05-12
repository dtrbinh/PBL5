# HƯỚNG DẪN CHẠY API PBL5

## CÁC BƯỚC ĐỂ CHẠY ĐƯỢC API
- **Bước 1**: Chuyển vào thư mục PBL5_backend: **cd PBL5_backend**
- **Bước 2**: Cài thư viện: **pip install -r requirements.txt**
- **Bước 3**: Chạy: **python app.py**

## CHI TIẾT CÁC API
1. **API quét mã barcode thẻ SV**: 
    - **Endpoint**: /students/scan-card
    - **Method**: POST
    - **Form_data**: student_card_img
    - **Http code when success**: 201

    ![image](https://user-images.githubusercontent.com/93651748/232287571-49f0025a-1ba3-4334-a4f9-5354b2afea03.png)

2. **API lấy tất cả học sinh**: 
    - **Endpoint**: /students
    - **Method**: GET

    ![image](https://user-images.githubusercontent.com/93651748/230786720-659d2726-3207-495e-a9ac-a1726938d42e.png)

3. **API thêm mới 1 học sinh**: 
    - **Endpoint**: /students
    - **Method**: POST
    - **Body**:
        {
            "id",
            "name",
            "class_name",
            "faculty",
        }
    
    1. Thành công:
    
        ![image](https://user-images.githubusercontent.com/93651748/232287415-46a76a02-b058-44c0-b41d-b16f95989264.png)

4. **API thêm mới nhiều học sinh**: 
    - **Endpoint**: /students/insertMany
    - **Method**: POST
    - **Body**:
        [{
            "id",
            "name",
            "class_name",
            "faculty",
        }, ...]
    
    1. Thành công:
    
        ![image](https://user-images.githubusercontent.com/93651748/232287415-46a76a02-b058-44c0-b41d-b16f95989264.png)

5. **API cập nhật học sinh**: 
    - **Endpoint**: /students/(id)
    - **Ví dụ**: /students/102200016
    - **Method**: PUT
    - **Body**:
        {
            "name",
            "class_name",
            "faculty",
        }
    
    1. Thành công:
    
        ![image](https://user-images.githubusercontent.com/93651748/232287415-46a76a02-b058-44c0-b41d-b16f95989264.png)

6. **API xóa 1 học sinh**: 
    - **Endpoint**: /students/(id)
    - **Ví dụ**: /students/102200016
    - **Method**: DELETE
    
    1. Thành công:
    
        ![image](https://user-images.githubusercontent.com/93651748/232287415-46a76a02-b058-44c0-b41d-b16f95989264.png)

7. **API đọc biển số xe**: 
    - **Endpoint**: /plates/read-plate-text
    - **Method**: POST
    - **Form_data**: plate_img
    - **Http code when success**: 201

    ![image](https://user-images.githubusercontent.com/93651748/232288098-6901e7e8-6eec-4e7c-b46e-7589c816f704.png)

8. **API lấy tất cả check-in**: 
    - **Endpoint**: /check-ins
    - **Method**: GET

9. **API tạo mới 1 check-in**: 
    - **Endpoint**: /check-ins
    - **Method**: POST
    - **Body**: number_plate, student_id, img_check_in

    1. Form data thiếu tham số:

        ![image](https://user-images.githubusercontent.com/93651748/230785693-17bfb386-ad1c-4d99-96f2-14ac01679912.png)

    2. Thành công:
        
        ![image](https://user-images.githubusercontent.com/93651748/236797702-f78de95e-1416-4870-9e6e-33fcb8d32f45.png)

10. **API cập nhật 1 check-in**: 
    - **Endpoint**: /check-ins
    - **Method**: PUT
    - **Body**: number_plate, student_id, img_check_in

    1. Form data thiếu tham số:

        ![image](https://user-images.githubusercontent.com/93651748/230785693-17bfb386-ad1c-4d99-96f2-14ac01679912.png)

    2. Thành công:
        
        ![image](https://user-images.githubusercontent.com/93651748/236797702-f78de95e-1416-4870-9e6e-33fcb8d32f45.png)

11. **API xóa 1 check-in**: 
    - **Endpoint**: /check-ins/(id)
    - **Ví dụ**: /check-ins/1
    - **Method**: DELETE

12. **API lấy tất cả log**: 
    - **Endpoint**: /logs
    - **Method**: GET

    ![image](https://user-images.githubusercontent.com/93651748/232287361-52ea8ad1-551a-4f97-aa49-1a1816531e56.png)

13. **API tạo mới log (dùng khi checkout)**: 
    - **Endpoint**: /logs
    - **Method**: POST

    - **Body**: number_plate, student_id, img_check_out

    1. Form data thiếu tham số:

        ![image](https://user-images.githubusercontent.com/93651748/230785693-17bfb386-ad1c-4d99-96f2-14ac01679912.png)

    2. Thành công:

        ![image](https://user-images.githubusercontent.com/93651748/232287137-af1a1c76-ae04-47bd-82f3-b048c9df39ab.png)

    3. Chưa check in:

        ![image](https://user-images.githubusercontent.com/93651748/230786609-320e73c9-6fa9-4230-beb9-be840f868979.png)

   4. Checkout thất bại:

        ![image](https://user-images.githubusercontent.com/93651748/230786637-0a62c5cc-e67a-4e17-ac98-899ce3402b66.png)


14. **API cập nhật 1 log**: 
    - **Endpoint**: /logs
    - **Method**: POST

    - **Body**: number_plate, student_id, img_check_out

15. **API xóa 1 log**: 
    - **Endpoint**: /logs/(id)
    - **Ví dụ**: /logs/1
    - **Method**: DELETE