from flask import Blueprint, request
from src.service.log_service import get_all_logs_service, create_log_service, \
    update_log_by_id_service, delete_log_by_id_service, find_log_by_id_service
logs = Blueprint('logs', __name__, url_prefix='/logs')

# Get all logs
@logs.route('', methods=['GET'])
def get_all_logs():
    return get_all_logs_service()

# Find log by id
@logs.route('/<int:id>', methods=['GET'])
def find_log_by_id(id):
    return find_log_by_id_service(id)

# add new log
@logs.route('', methods=['POST'])
def create_log():
    return create_log_service()

# update log
@logs.route('/<int:id>', methods=['PUT'])
def update(id):
    return update_log_by_id_service(id)

# delete log
@logs.route('/<int:id>', methods=['DELETE'])
def delete(id):
    return delete_log_by_id_service(id)
