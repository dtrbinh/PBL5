from flask import Blueprint, request
from src.service.plate_service import read_plate_text_service

plates = Blueprint('plates', __name__, url_prefix='/plates')

@plates.route('/read-plate-text', methods=['POST'])
def read_plate_text():
    return read_plate_text_service()
