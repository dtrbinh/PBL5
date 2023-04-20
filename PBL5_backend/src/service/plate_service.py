from datetime import date
import os
from random import randint
from ..util.model import getPlateTextFromImage
from flask import jsonify, request, jsonify, url_for

from werkzeug.utils import secure_filename

def read_plate_text_service():
    if ('plate_img' in request.files):
        plate_image = request.files['plate_img']

        # Tạo đường dẫn ảnh tạm
        prefix = f'SWM-{randint(10,900)}-{date.today()}'

        # nếu có file ảnh
        if plate_image.filename != '':
            filename = secure_filename(plate_image.filename)
            filename = f'{prefix}-{filename}'
            plate_image.save(os.path.join(
                'src/static/upload',
                filename
            ))
            imgPath = f'src/static/upload/{filename}'

            # lấy text trên biển số xe
            plate_number = getPlateTextFromImage(imgPath)

            # nếu có plate_number
            if plate_number is None:
                return jsonify(
                    {
                        "message": "Can not get plate text number",
                        "status": 0
                    }
                ), 400
            else:
                print(filename)
                return jsonify({
                    "plate_text": plate_number,
                    "message": "SUCCEESS",
                    "plate_img": url_for('static', filename='upload/' + filename, _external=True),
                    "status": 1
                }), 201
    else:
        return jsonify({
                "message": "Validation request error",
                "status": 0
            }), 400
    
