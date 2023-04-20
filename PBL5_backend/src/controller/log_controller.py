from flask import Blueprint, request
from src.service.log_service import get_all_logs_service, create_log_service
logs = Blueprint('check_outs', __name__)

@logs.route('/logs', methods=['GET'])
def get_all_logs():
    return get_all_logs_service(), 200

@logs.route('/check-outs', methods=['POST'])
def create_log():
    return create_log_service()

