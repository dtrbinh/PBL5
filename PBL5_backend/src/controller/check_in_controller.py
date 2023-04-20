from flask import Blueprint, request
from src.service.check_in_service import get_all_check_ins_service, create_check_in_service

check_ins = Blueprint('check_ins', __name__, url_prefix='/check-ins')

@check_ins.route('/', methods=['GET'])
def get_all_check_ins():
    return get_all_check_ins_service(), 200

@check_ins.route('/', methods=['POST'])
def create():
    return create_check_in_service()

