from flask import Blueprint, request
from src.service.check_in_service import get_all_check_ins_service, create_check_in_service, \
    delete_check_in_by_id_service, update_check_in_by_id_service, find_check_in_by_id_service

check_ins = Blueprint('check_ins', __name__, url_prefix='/check-ins')

# Get all check in
@check_ins.route('', methods=['GET'])
def get_all_check_ins():
    return get_all_check_ins_service()

# Find check in by id
@check_ins.route('/<int:id>', methods=['GET'])
def find_check_in_by_id(id):
    return find_check_in_by_id_service(id)

# Add new check in
@check_ins.route('', methods=['POST'])
def create_check_in():
    return create_check_in_service()

# Update check in
@check_ins.route('/<int:id>', methods=['PUT'])
def update_check_in_by_id(id):
    return update_check_in_by_id_service(id)

# delete check in
@check_ins.route('/<int:id>', methods=['DELETE'])
def delete_check_in_by_id(id):
    return delete_check_in_by_id_service(id)