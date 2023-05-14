from flask import Blueprint, request
from src.service.plate_service import read_plate_text_service, hello

# plates = Blueprint('plates', __name__, url_prefix='/plates')
plates = Blueprint('plates', __name__)

@plates.route('/plates/read-plate-text', methods=['POST'])
def read_plate_text():
    return read_plate_text_service()

@plates.route('/', methods=['GET'])
def hello_wolrd():
    return hello()
