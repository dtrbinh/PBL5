FROM python:3.9.13
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
RUN apt-get update && apt-get install -y libgl1-mesa-glx libzbar0
COPY . .
CMD ["python","app.py"]