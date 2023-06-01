from werkzeug.utils import secure_filename
from random import randint
from datetime import date
import os

def uploadImage(image, folder):
    # Tạo đường dẫn ảnh tạm
    prefix = f'SWM-{randint(10, 900)}-{date.today()}'
    filename = secure_filename(image.filename)
    filename = f'{prefix}-{filename}'
    imgPath = os.path.join('src/static/upload/image', folder, filename)
    image.save(imgPath)
    return imgPath
