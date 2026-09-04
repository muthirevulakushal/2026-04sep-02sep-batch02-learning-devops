FROM python:3.9-slim
WORKDIR /usr/local/app

# Install the application dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy in the source code
COPY app.py ./app.py
EXPOSE 5000

# Setup an app user so the container doesn't run as the root user
RUN useradd myuser
USER myuser

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