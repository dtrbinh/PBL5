import os 
from dotenv import load_dotenv

load_dotenv()
SECRET_KEY = os.environ.get("KEY")
basedir = os.path.abspath(os.path.dirname(__file__))
SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'pbl5.db')
SQLALCHEMY_TRACK_MODIFICATIONS = False