from datetime import date
import os
from random import randint
import tempfile
from flask import Flask, request, jsonify

from datetime import date
from random import randint
from werkzeug.utils import secure_filename

import torch
import numpy as np
import cv2
from imutils import perspective
import numpy as np
import functools
from skimage.filters import threshold_local
import imutils
from keras.models import load_model
from tensorflow.keras.utils import img_to_array


app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'static/'

import numpy as np
from util.model import getPlateTextFromImage

@app.route('/scan-plate', methods=['POST'])
def scanPlate():
    if 'image' not in request.files:
        return 'No image uploaded', 400
    image_file = request.files['image']
    prefix = f'SWM-{randint(10,900)}-{date.today()}'
    if image_file.filename != '':
        filename = secure_filename(image_file.filename)
        filename = f'{prefix}-{filename}'
        image_file.save(os.path.join(
            app.config['UPLOAD_FOLDER'],
            filename
        ))

    try:
        imgPath = f'./static/{filename}'
        plate_text = getPlateTextFromImage(imgPath)
        if plate_text is None:
            return jsonify({
                "status": 0,
                "data": {
                    "number_plate": "underfined",
                    "message": "FAILED",
                }
            }), 400
            
        return jsonify({
                "status": 1,
                "data": {
                    "number_plate": plate_text,
                    "message": "SUCCESS",
                }
            }
        ), 200
    except Exception as e:
        return jsonify({
            "status": 0,
            "data": {
                "number_plate": "underfined",
                "message": "FAILED",
            }
        }),400

if __name__ == "__main__":
    app.run(host='127.0.0.1', port=3000)

