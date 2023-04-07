from flask import Flask, request, Blueprint
from .controller.studentController import students
from .extension import db, ma
from .model import Students, CheckIns, CheckOuts
import os

def create_app(config_file = "config.py"):
    app = Flask(__name__)
    app.config.from_pyfile(config_file)
    db.init_app(app)
    ma.init_app(app)
    with app.app_context():
        db.create_all()
    app.register_blueprint(students)
    return app