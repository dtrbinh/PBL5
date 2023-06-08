import os
from ..util.model import getPlateTextFromImage
from flask import jsonify, request, jsonify, url_for
from ..util.upload.uploadImageUtil import uploadImage

def read_plate_text_service():
    if 'plate_img' in request.files:
        plate_image = request.files['plate_img']

        # nếu có file ảnh
        if plate_image.filename != '':
            # Get img path
            img_path = uploadImage(plate_image, 'license-plates')
            filename = os.path.basename(img_path)
            # lấy text trên biển số xe
            number_plate = getPlateTextFromImage(img_path)

            # nếu khong có plate_number
            if number_plate is None:
                print("Can not get plate text number")
                return jsonify({
                    "data": {
                        "number_plate": "undefined",
                        "plate_img": "undefined",
                    },
                    "message": "Can not get plate text number",
                    "status": 0
                }), 400
            else:
                print("Number liscense plate: ", number_plate)
                return jsonify({
                    "data": {
                        "number_plate": number_plate,
                        "plate_img": url_for('static', filename='upload/image/license-plates/' + filename, _external=True),
                    },
                    "message": "SUCCESS",
                    "status": 1
                }), 201
    else:
        print("Validation request error")
        return jsonify({
                "data": {
                    "number_plate": "undefined",
                    "plate_img": "undefined",
                },
                "message": "Validation request error",
                "status": 0
            }), 400
