FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]

# docker images
# docker ps
# docker rm -f <container_id>
# docker rmi -f <image_id>
# docker rm -f $(docker ps -a -q)
# docker rmi -f $(docker images -a -q)

# docker build -t mlapp:latest .
# docker run -p 5000:5000 mlapp:latest

# docker pull ssadcloud/mlapp:latest
# docker run -p 5000:5000 ssadcloud/mlapp:latest