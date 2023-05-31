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

    ![image](https://github.com/dtrbinh/PBL5/assets/93651748/44f5f7fc-7866-4d20-b4e5-8d403676ac8f)

2. **API lấy tất cả học sinh**: 
    - **Endpoint**: /students
    - **Method**: GET

    ![image](https://github.com/dtrbinh/PBL5/assets/93651748/b1cc03c8-e326-447e-ba89-c717f66ac39a)

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
    
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/a0a89e30-7e0b-44dc-b6e7-7bdb6aea977e)

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
    
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/57a39ec4-f411-4ce1-97e0-900c23eae1be)

5. **API cập nhật học sinh**: 
    - **Endpoint**: /students/(id)
    - **Ví dụ**: /students/102200024
    - **Method**: PUT
    - **Body**:
        {
            "name",
            "class_name",
            "faculty",
        }
    
    1. Thành công:
    
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/a51a51f6-5145-4f68-b442-840b11c4743f)

6. **API xóa 1 học sinh**: 
    - **Endpoint**: /students/(id)
    - **Ví dụ**: /students/102200024
    - **Method**: DELETE
    
    1. Thành công:
    
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/da9dc03b-90da-4fd0-9a6f-62b408ad23e7)
7. **API xem chi tiết 1 học sinh**:
    - **Endpoint**: /students/(id)
    - **Ví dụ**: /students/102200010
    - **Method**: GET
    - **Thành công**:
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/c8f282db-eef0-4a1e-92e8-9b3b4591febf)
    - **Thất bại**:
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/4658d829-5635-4e8e-8c76-a1a28a324e02)

8. **API thêm sinh viên bằng file csv**:
    - **Endpoint**: /students/import-file
    - **Body Form data**: file_students (chú ý là file csv)
    - **Method**: POST

    ![image](https://github.com/dtrbinh/PBL5/assets/93651748/dac685d1-b5b8-49aa-b0bd-703a093e4c80)


9. **API đọc biển số xe**: 
    - **Endpoint**: /plates/read-plate-text
    - **Method**: POST
    - **Form_data**: plate_img
    - **Http code when success**: 201

    ![image](https://github.com/dtrbinh/PBL5/assets/93651748/e34355b0-7a39-4b05-a840-01d3a37a1168)

10. **API lấy tất cả check-in**: 
    - **Endpoint**: /check-ins
    - **Method**: GET
    
    ![image](https://github.com/dtrbinh/PBL5/assets/93651748/d34ecf3b-d5da-410e-9265-d88377b5424a)

11. **API tạo mới 1 check-in**: 
    - **Endpoint**: /check-ins
    - **Method**: POST
    - **Body**: number_plate, student_id, img_check_in

    1. Form data thiếu tham số:

        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/c97d5c81-7910-4c37-9190-c1f16dda953b)

    2. Thành công:
        
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/c6687a9f-c524-4ee0-acef-8f8969a1e2a5)
    3. Trường hợp xe đã được check in trước đó: trả về status 400
    
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/bf3de4a9-ddf3-439b-980f-fb872b0f5542)  


12. **API cập nhật 1 check-in**: 
    - **Endpoint**: /check-ins/(id)
    - **Method**: PUT
    - **Body**: number_plate, student_id, img_check_in

    1. Form data thiếu tham số:

        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/b5e302d7-afe0-4490-98e2-47fc70c68e6a)

    2. Thành công:
        
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/3456cada-87ab-4bdd-b906-b865cc4845e8)

13. **API xóa 1 check-in**: 
    - **Endpoint**: /check-ins/(id)
    - **Ví dụ**: /check-ins/1
    - **Method**: DELETE

    ![image](https://github.com/dtrbinh/PBL5/assets/93651748/7744ec41-0818-402b-9030-8122b9eb06b3)


14. **API xem chi tiết 1 check-in**: 
    - **Endpoint**: /check-ins/(id)
    - **Ví dụ**: /check-ins/1
    - **Method**: GET
    - **Thành công**:
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/bd712c37-b3b8-40f1-8113-c510c462cfbc)
    - **Thất bại**:
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/48ca7b57-ea23-4950-badd-e8a4c72ca41b)

15. **API lấy tất cả log**: 
    - **Endpoint**: /logs
    - **Method**: GET

    ![image](https://github.com/dtrbinh/PBL5/assets/93651748/3134f79f-31b2-424e-80a6-c80f6d634fec)
    
16. **API tạo mới log (dùng khi checkout)**: 
    - **Endpoint**: /logs
    - **Method**: POST

    - **Body**: number_plate, student_id, img_check_out

    1. Form data thiếu tham số:

        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/5e6c6ca1-b73f-4297-8b97-fea1fdcd7819)

    2. Thành công:

        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/40b434d6-7f09-4892-ad4d-340542d5b4cc)

    3. Chưa check in:

        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/2f78a3b7-ac2b-4d41-a41f-eec5fcf8d358)

   4. Checkout thất bại:

        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/58a150f2-6b1b-4682-9e08-66e6e679797b)


17. **API cập nhật 1 log**: 
    - **Endpoint**: /logs/(id)
    - **Ví dụ**: /logs/1
    - **Method**: PUT

    - **Body**: number_plate, student_id, img_check_out, img_check_in, time_check_in, time_check_out
    
    ![image](https://github.com/dtrbinh/PBL5/assets/93651748/45fa8ebe-6a3b-4db4-a6c8-c8ca9d773a18)


18. **API xóa 1 log**: 
    - **Endpoint**: /logs/(id)
    - **Ví dụ**: /logs/1
    - **Method**: DELETE
    
    ![image](https://github.com/dtrbinh/PBL5/assets/93651748/8d0ff48a-05c3-4c18-b689-81e583d27396)


19. **API chi tiết 1 log**: 
    - **Endpoint**: /logs/(id)
    - **Ví dụ**: /logs/1
    - **Method**: GET
    - **Thành công**:
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/aded991f-b672-4a74-9126-736bfcc87358)
    - **Thất bại**:
        ![image](https://github.com/dtrbinh/PBL5/assets/93651748/9761a21f-4cf4-4400-8020-fb0f68d8980a)

