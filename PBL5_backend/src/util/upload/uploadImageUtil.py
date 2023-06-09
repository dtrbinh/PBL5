from io import BytesIO
import numpy as np
from werkzeug.utils import secure_filename
from random import randint
from datetime import date
import os
from PIL import Image

def uploadImage(image, folder):
    # Đọc dữ liệu từ đối tượng FileStorage
    image_data = image.read()

    # Tạo đối tượng Image từ dữ liệu ảnh
    imagePIL = Image.open(BytesIO(image_data))

    # Tạo đường dẫn ảnh tạm
    prefix = f'SWM-{randint(10, 900)}-{date.today()}'
    filename = secure_filename(image.filename)
    filename = f'{prefix}-{filename}'
    imgPath = os.path.join('src/static/upload/image', folder, filename)

    # Kiểm tra điều kiện để resize ảnh
    if folder == 'license-plates' and imagePIL.size[0] == 640 and imagePIL.size[1] == 480:
        newImg = resize_image(imagePIL)  # Resize ảnh đã đọc về 640x640
        newImg.save(imgPath)  # Lưu ảnh đã resize
    else:
        imagePIL.save(imgPath)  # Lưu ảnh gốc

    return imgPath

def resize_image(image):
    # Tạo ảnh mới với kích thước mới và đặt màu nền thành đen
    new_image = Image.new('RGB', (640, 640), (0, 0, 0))

    # Tính toán vị trí để chèn ảnh cũ vào ảnh mới
    x_offset = (640 - image.size[0]) // 2
    y_offset = (640 - image.size[1]) // 2

    # Chèn ảnh cũ vào ảnh mới
    new_image.paste(image, (x_offset, y_offset))

    return new_image

