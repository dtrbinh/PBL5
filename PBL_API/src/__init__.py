from flask import Flask
from .controller.student_controller import students
from .controller.check_in_controller import check_ins
from .controller.log_controller import logs
from .controller.plate_controller import plates
from .extension import db, ma

def create_app(config_file = "config.py"):
    app = Flask(__name__)
    app.config.from_pyfile(config_file)
    db.init_app(app)
    ma.init_app(app)
    with app.app_context():
        db.create_all()
    app.register_blueprint(students)
    app.register_blueprint(check_ins)
    app.register_blueprint(logs)
    app.register_blueprint(plates)
    return app
