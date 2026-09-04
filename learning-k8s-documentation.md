## Project Overview
This example demonstrates a simple Flask API running inside a Docker container.

### Expected Response
```text
Hello from Docker + Kubernetes!
```

## Project Structure
```text
python-docker-k8s-app/
│
├── app.py
├── requirements.txt
├── Dockerfile
├── .dockerignore
└── k8s/
    ├── deployment.yaml
    └── service.yaml
```

## Application Code
### app.py
```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Docker + Kubernetes!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

### requirements.txt
```txt
flask==2.3.3
```

### Dockerfile
```dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

### .dockerignore
```text
__pycache__/
*.pyc
*.pyo
*.pyd
.env
.git
```

## Build Docker Image
```bash
docker build -t myapp:latest .
```

## Run Container
```bash
docker run -p 5000:5000 myapp:latest
```

## Verify Application
Open:

```text
http://localhost:5000
```

Output:

```text
Hello from Docker + Kubernetes!
```


## Common Docker Commands
### Install Java & Maven

```bash
sudo apt-get update -y
sudo apt-get install openjdk-17-jdk -y
sudo apt-get install maven -y
```

### Build Maven Project
```bash
mvn clean package
```

### Docker Commands
```bash
docker build -t myapp:latest .
docker run -p 8080:8080 myapp:latest

docker images
docker ps

docker rm -f <container_id>
docker rmi -f <image_id>

docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -a -q)
```

# 3. Docker Storage and Volumes
## Overview
Containers are ephemeral by default. Any data stored inside a container is lost when the container is removed.
Docker Volumes provide persistent storage.

## Storage Types
### Docker Volumes (Recommended)

* Managed by Docker
* Stored under:

```text
/var/lib/docker/volumes/
```

* Suitable for production workloads

### Bind Mounts

* Direct mapping between host and container
* Ideal for local development



## Create a Volume

```bash
docker volume create my_data_volume
```

### List Volumes

```bash
docker volume ls
```

### Inspect Volume

```bash
docker volume inspect my_data_volume
```



## Attach Volume to a Container

### Preferred Syntax

```bash
docker run -it \
--mount type=volume,source=my_data_volume,target=/app/data \
ubuntu
```

### Shorthand Syntax

```bash
docker run -it -v my_data_volume:/app/data ubuntu
```



## Data Persistence Demo

### Create File

```bash
docker run -it -v my_data_volume:/data ubuntu

cd /data
touch hello.txt
exit
```

### Verify Persistence

```bash
docker run -it -v my_data_volume:/data ubuntu

ls /data
```

Output:

```text
hello.txt
```



## Volume vs Bind Mount

| Feature        | Docker Volume | Bind Mount      |
| -- | - |  |
| Managed By     | Docker        | User            |
| Portability    | High          | Low             |
| Security       | Better        | Lower           |
| Production Use | Recommended   | Not Recommended |



# 4. Docker Networking

## Overview

Docker networking enables communication between:

* Containers
* Host systems
* External services



## Default Networks

```bash
docker network ls
```

Default networks:

* bridge
* host
* none



## Create Custom Network

```bash
docker network create --driver bridge app-network
```

### Benefits

* Network isolation
* Built-in DNS resolution
* Improved security



## Service Discovery

Containers on the same network communicate using container names.

Example:

```text
db:5432
```

No IP address is required.



# 5. Docker Compose

## Overview

Docker Compose enables deployment of multi-container applications using a single YAML file.

### docker-compose.yml

```yaml
version: "3.9"

services:
  web:
    build: .
    container_name: flask-app
    ports:
      - "5000:5000"
    depends_on:
      - db
    networks:
      - backend

  db:
    image: postgres:15
    container_name: postgres-db
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend

volumes:
  db-data:

networks:
  backend:
```



## Deploy

```bash
docker-compose up -d --build
```

## Stop

```bash
docker-compose down
```

### Benefits

* Single-command deployment
* Automatic networking
* Persistent storage
* Simplified service management



# 6. Multi-Stage Docker Builds

## Purpose

Reduce image size and improve security by separating build and runtime stages.

### Example Dockerfile

```dockerfile
FROM python:3.11 AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim

WORKDIR /app

RUN useradd -m appuser

COPY --from=builder /root/.local /home/appuser/.local

ENV PATH=/home/appuser/.local/bin:$PATH

COPY . .

USER appuser

CMD ["python", "app.py"]
```

### Advantages

* Smaller images
* Faster deployment
* Lower attack surface
* Better security



# 7. Container Security with Trivy

## What is Trivy?

Trivy is an open-source vulnerability scanner for:

* Container images
* OS packages
* Dependencies
* Secrets
* Misconfigurations



## Installation

```bash
sudo apt install trivy
```

## Scan Image

```bash
trivy image flask-app:latest
```

### Severity Levels

| Level    | Description               |
| -- | - |
| LOW      | Minor impact              |
| MEDIUM   | Moderate risk             |
| HIGH     | Serious vulnerability     |
| CRITICAL | Immediate action required |



# 8. AWS EC2 Environment Setup

## Connect to EC2

```bash
ssh -i k8s.pem ubuntu@<public-ip>
```

## Initial Workspace Setup

```bash
sudo su
mkdir workspace
cd workspace
```



# 9. Essential Software Installation

## Git

```bash
sudo apt-get install git -y
git --version
```

## Java 17

```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
```

Configure:

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

Verify:

```bash
java -version
echo $JAVA_HOME
```

## Maven

```bash
sudo apt install maven -y
mvn --version
```



# 10. Jenkins Installation

## Install Jenkins

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins
```
### Retrieve Admin Password

```bash
cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Grant Jenkins Sudo Access

```bash
sudo visudo
```

Add:

```text
jenkins ALL=(ALL) NOPASSWD: ALL
```



# 11. AWS CLI Installation

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o awscliv2.zip

unzip awscliv2.zip

sudo ./aws/install
```

Verify:

```bash
aws --version
```

Configure:

```bash
aws configure
```



# 12. Docker Installation

## Ubuntu

```bash
sudo apt update
sudo apt install docker.io -y
```

## Amazon Linux

```bash
sudo yum install docker -y
```

Verify:

```bash
docker --version
```



# 13. Kubernetes Tools Installation

## kubectl

```bash
curl -LO \
"https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

```bash
sudo install -o root -g root -m 0755 kubectl \
/usr/local/bin/kubectl
```



## KIND

### Intel Mac

```bash
curl -Lo ./kind \
https://kind.sigs.k8s.io/dl/latest/kind-darwin-amd64
```

### Apple Silicon

```bash
curl -Lo ./kind \
https://kind.sigs.k8s.io/dl/latest/kind-darwin-arm64
```



# 14. Kubernetes Fundamentals & Commands

## Cluster

```bash
kubectl get nodes
kind get clusters
```

## Workloads

```bash
kubectl get pods
kubectl get deployments
```

## Deployment

```bash
kubectl config set-context --current --namespace=kumar-ns
kubectl apply -f deployment.yaml
kubectl delete -f deployment.yaml
```

## Pod Access

```bash
kubectl exec -it my-pod -- /bin/sh
```

## Port Forwarding

```bash
kubectl port-forward svc/my-service 9090:9090
```


## List Workspaces / Namespaces
kubectl get namespaces


Short form:

kubectl get ns


List all resources in all namespaces:

kubectl get all --all-namespaces

Switch Workspace / Namespace

Set the default namespace for your current kubectl context:

kubectl config set-context --current --namespace=<namespace-name>


Example:

kubectl config set-context --current --namespace=default
kubectl config set-context --current --namespace=kumar-ns



Check the current context and namespace:

kubectl config view --minify --output 'jsonpath={..namespace}'


List available contexts:

kubectl config get-contexts


Switch Kubernetes context/cluster:

kubectl config use-context <context-name>

List Deployments and Services Across All Workspaces

Deployments:

kubectl get deployments --all-namespaces


Services:

kubectl get services --all-namespaces


Both:

kubectl get deployments,services --all-namespaces

Delete All Deployments Across All Workspaces
kubectl delete deployments --all --all-namespaces

Delete All Services Across All Workspaces
kubectl delete services --all --all-namespaces

Delete Both Across All Workspaces
kubectl delete deployments,services --all --all-namespaces


⚠️ This last command is cluster-wide and destructive. It deletes every Deployment and Service in every namespace, including resources in namespaces such as kube-system.

Safer: delete only from one workspace
kubectl delete deployments --all -n <namespace>
kubectl delete services --all -n <namespace>


For example:

kubectl delete deployments --all -n dev
kubectl delete services --all -n dev

# 15. Terraform Installation

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg -y
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
```

Verify:

```bash
terraform version
```



# 16. Amazon EKS Management with eksctl

## Install eksctl
-- https://docs.aws.amazon.com/eks/latest/eksctl/installation.html  


```bash

# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl

```



## Create Cluster

```bash
eksctl create cluster \
--name sigmaEKS-Cluster \
--region us-east-1 \
--nodegroup-name sigmaEKS-Cluster-NG \
--node-type t3.medium \
--nodes 3 \
--nodes-min 2 \
--nodes-max 5 \
--ssh-access \
--ssh-public-key kp \
--managed
```

kubectl config set-context --current --namespace=default

eksctl get clusters --region us-east-1

## Delete Cluster

```bash
eksctl delete cluster \
--name sigmaEKS-Cluster \
--region us-east-1
```



# 17. Jenkins CI/CD Pipeline

## Build Application

```bash
mvn clean package
```

## Build Docker Image

```bash
docker build -t myapp .
```

## Push to Docker Hub

```bash
docker tag myapp username/myapp:latest
docker push username/myapp:latest
```

## Push to AWS ECR

```bash
aws ecr get-login-password \
--region us-east-2 \
| docker login \
--username AWS \
--password-stdin <account>.dkr.ecr.us-east-2.amazonaws.com
```

```bash
docker tag myapp:latest \
<account>.dkr.ecr.us-east-2.amazonaws.com/myapp:latest
```

```bash
docker push \
<account>.dkr.ecr.us-east-2.amazonaws.com/myapp:latest
```



# 18. Provision Amazon EKS Using Terraform

## Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

## Configure kubectl

```bash
aws eks update-kubeconfig \
--region us-east-2 \
--name <cluster-name>
```

## Cleanup

```bash
terraform destroy
```



# 19. Amazon EKS + Amazon EFS Production Setup

## Architecture

```text
AWS VPC
│
├── Public Subnets
│   └── NAT Gateway
│
├── Private Subnets
│   ├── EKS Nodes
│   └── EFS Mount Targets
│
├── EKS Cluster
│   └── EFS CSI Driver
│
└── Amazon EFS
```



## Deployment Workflow

### Initialize Terraform

```bash
terraform init
```

### Apply Infrastructure

```bash
terraform apply -auto-approve
```

### Configure kubectl

```bash
aws eks update-kubeconfig \
--region us-east-1 \
--name main-eks-cluster
```

### Install EFS CSI Driver

```bash
helm repo add aws-efs-csi-driver \
https://kubernetes-sigs.github.io/aws-efs-csi-driver/
```

```bash
helm repo update
```

```bash
helm upgrade --install \
aws-efs-csi-driver \
aws-efs-csi-driver/aws-efs-csi-driver \
--namespace kube-system
```



## Validation

```bash
kubectl get pods
kubectl get pvc
kubectl exec -it efs-test -- df -h
```



## Security Best Practices

* Use private subnets
* Enable encryption at rest
* Enable encryption in transit
* Restrict security groups
* Use IRSA



## Cost Optimization

Recommended node types:

```text
t3.small
t3.medium
```

Terraform example:

```hcl
lifecycle_policy {
  transition_to_ia = "AFTER_30_DAYS"
}
```



## Common Issues
| Issue         | Cause                | Resolution        |
| - | -- | -- |
| PVC Pending   | CSI Driver Failure   | Verify CSI Driver |
| Mount Timeout | Security Group Rules | Open Port 2049    |
| Pod Pending   | No Worker Nodes      | Verify Node Group |



# 20. Production Best Practices
## Docker
* Use minimal base images
* Avoid running as root
* Use multi-stage builds
* Scan images regularly

## Kubernetes
* Use namespaces
* Configure resource limits
* Implement readiness probes
* Implement liveness probes
* Store secrets securely

## AWS
* Use private subnets
* Enable encryption
* Apply least-privilege IAM
* Monitor with CloudWatch

## CI/CD
* Automate security scanning
* Use image versioning
* Implement rollback strategies
* Manage infrastructure as code



## Learning Path
```text
Docker Fundamentals
        │
        ▼
Docker Networking & Storage
        │
        ▼
Docker Compose
        │
        ▼
Container Security (Trivy)
        │
        ▼
Kubernetes Fundamentals
        │
        ▼
Jenkins CI/CD
        │
        ▼
AWS ECR
        │
        ▼
Amazon EKS
        │
        ▼
Terraform IaC
        │
        ▼
Amazon EFS Integration
        │
        ▼
Production DevOps Platform
```



# PostgreSQL Installation and Configuration on Linux

## Overview
PostgreSQL runs natively and efficiently on Linux, which is widely considered its primary target platform due to its Unix-centric architecture. Setting up PostgreSQL on a Linux server involves installing the required packages via your distribution's package manager, managing the database service, and performing initial role and database configuration.


# Step 1: Install PostgreSQL
Install PostgreSQL from your Linux distribution's official repositories.

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
```

> Note: For access to the newest PostgreSQL releases, consider using the official PostgreSQL APT Repository.

# Step 2: Manage the PostgreSQL Service

Linux systems use `systemctl` to manage PostgreSQL as a background service.

### Start PostgreSQL
```bash
sudo systemctl start postgresql
```

### Enable Automatic Startup at Boot
```bash
sudo systemctl enable postgresql
```

### Verify Service Status
```bash
sudo systemctl status postgresql
```
A successful status check should show PostgreSQL as active and running.

# Step 3: Access the PostgreSQL Command Line
PostgreSQL uses role-based authentication and typically maps database roles to Linux system users through peer or ident authentication.

A default administrative Linux user named `postgres` is created during installation.

### Open the PostgreSQL Shell

```bash
sudo -u postgres psql
```

After logging in, the prompt changes to:

```text
postgres=#
```

### Exit the PostgreSQL Shell

```sql
\q
```

# Step 4: Create an Application User and Database
For security reasons, applications should not connect using the PostgreSQL superuser account.
Connect to PostgreSQL and create a dedicated user and database.

### Create a Database User

```sql
CREATE USER my_app_user WITH PASSWORD 'secure_password_here';
```

### Create a Database

```sql
CREATE DATABASE my_app_db;
```

### Grant Privileges

```sql
GRANT ALL PRIVILEGES ON DATABASE my_app_db TO my_app_user;
```

This configuration allows the application user to manage and access the specified database.


# Step 5: Enable Remote Connections (Optional)

By default, PostgreSQL only accepts connections from localhost.

If applications or users need to connect from another machine, modify PostgreSQL's configuration.

## 1. Update postgresql.conf

Locate the PostgreSQL configuration file:

### Ubuntu / Debian

```text
/etc/postgresql/<version>/main/postgresql.conf
```


Find the following setting:

```ini
#listen_addresses = 'localhost'
```

Change it to:

```ini
listen_addresses = '*'
```

This allows PostgreSQL to listen on all network interfaces.



## 2. Update pg_hba.conf

Locate the Host-Based Authentication file:

```text
pg_hba.conf
```

Add a rule permitting connections from your network.

```text
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             192.168.1.0/24          scram-sha-256
```

### Recommendation

Restrict access to trusted IP ranges whenever possible. Avoid allowing unrestricted access from the internet.



## 3. Restart PostgreSQL

Apply the configuration changes.

```bash
sudo systemctl restart postgresql
```



## 4. Configure Firewall Rules

Ensure the PostgreSQL port (5432) is accessible from approved hosts.

Examples:

### UFW (Ubuntu)

```bash
sudo ufw allow 5432/tcp
```

### firewalld (RHEL/Rocky/AlmaLinux)

```bash
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload
```


# Verification

Test connectivity locally:

```bash
psql -U my_app_user -d my_app_db
```

For remote access:

```bash
psql -h <server-ip> -U my_app_user -d my_app_db
```



I'll create this as a beginner-friendly learning document, written from the perspective of an Apache Kafka Developer, with real-world examples and a step-by-step learning path.

===========================================================================================================
# Apache Kafka Complete Beginner Guide
===========================================================================================================

# 1. What is Apache Kafka?
Apache Kafka is a distributed event streaming platform used to collect, store, process, and transfer data in real time.
Think of Kafka as a high-speed messaging system that sits between applications.

### Simple Definition
Kafka allows applications to:

 * Send messages
 * Store messages
 * Process messages
 * Consume messages
in real time.

# 2. Why Do We Need Kafka?
Before Kafka:

```text
Application A > Application B
```

Problems:

 * Tight coupling
 * Slow communication
 * System failures affect other systems
 * Difficult to scale

With Kafka:

```text
Application A
      |
      V
    Kafka
   /  |  \
  /   |   \
 B    C    D
```

Benefits:

* Decoupled architecture
* High performance
* Fault tolerant
* Scalable
* Real-time processing



# 3. Real-Time Example: Food Delivery Application

Imagine a food delivery platform like:
 * Order Service
 * Payment Service
 * Restaurant Service
 * Delivery Service
 * Notification Service

Customer places order.

Without Kafka:

```text
Order Service
    |
    +--> Payment Service
    |
    +--> Restaurant Service
    |
    +--> Delivery Service
    |
    +--> Notification Service
```

If one service is down, the flow breaks.

With Kafka:

```text
Order Service
      |
      V
   Kafka Topic
      |
--
|      |      |       |
V      V      V       V

Payment
Restaurant
Delivery
Notification
```

Every service independently consumes the event.


# 4. Kafka Architecture

```text
Producer
    |
    V
++
|  Topic  |
++
    |
    V
Consumer
```

More Detailed:

```text
Producer
   |
   V

+-+
| Kafka Broker   |
+-+
      |
      V

   Topic
      |
      V

Consumer Group
```

# 5. Core Kafka Concepts

Understanding these concepts is the key to mastering Kafka.


## Concept 1: Producer

Producer sends messages to Kafka.

Example:

```java
Order Created
Payment Completed
User Registered
```

Real-world:

Amazon Order Service sends:

```json
{
  "orderId": 101,
  "status": "CREATED"
}
```

to Kafka.



## Concept 2: Consumer

Consumer reads messages from Kafka.

Example:

Delivery Service receives:

```json
{
  "orderId": 101,
  "status": "CREATED"
}
```

and starts delivery processing.



## Concept 3: Broker

A Kafka Server is called a Broker.

Example:

```text
Broker-1
Broker-2
Broker-3
```

Together they form a Kafka Cluster.



## Concept 4: Topic

Topic is a logical channel where messages are stored.

Examples:

```text
orders
payments
customers
deliveries
```

Think of Topic as a folder.



## Concept 5: Partition

Topics are divided into partitions.

Example:

Topic:

```text
orders
```

Partitions:

```text
orders-0
orders-1
orders-2
```

Benefits:

* Parallel processing
* Scalability
* High throughput



# Real Example

Suppose 1 Million orders arrive.

Instead of:

```text
orders
```

Use:

```text
Partition-0
Partition-1
Partition-2
Partition-3
```

Messages distribute across partitions.



## Concept 6: Offset

Every message gets a unique number.

Example:

```text
Offset 0
Offset 1
Offset 2
Offset 3
```

Kafka uses offsets to track message consumption.



Example:

```text
Offset 0 -> Order 101
Offset 1 -> Order 102
Offset 2 -> Order 103
```

Consumer remembers:

```text
Last Read Offset = 2
```

Next read starts from Offset 3.



## Concept 7: Consumer Group

Multiple consumers can work together.

Example:

```text
Consumer Group

Consumer-1
Consumer-2
Consumer-3
```

Partitions get distributed.

```text
Partition-0 -> Consumer-1
Partition-1 -> Consumer-2
Partition-2 -> Consumer-3
```

Benefits:

* Load balancing
* Parallel processing



# 6. Kafka Installation

## Download Kafka

```bash
wget https://downloads.apache.org/kafka/latest/kafka_2.13-<version>.tgz
```

Extract:

```bash
tar -xzf kafka_2.13-<version>.tgz
cd kafka_2.13-<version>
```



## Start Kafka

### Start KRaft Mode (Latest Kafka)

```bash
bin/kafka-storage.sh random-uuid
```

Format Storage:

```bash
bin/kafka-storage.sh format \
-t <UUID> \
-c config/kraft/server.properties
```

Start Server:

```bash
bin/kafka-server-start.sh \
config/kraft/server.properties
```



# 7. Create Your First Topic

```bash
bin/kafka-topics.sh \
--create \
--topic orders \
--bootstrap-server localhost:9092
```

Verify:

```bash
bin/kafka-topics.sh \
--list \
--bootstrap-server localhost:9092
```

Output:

```text
orders
```



# 8. Create Producer

Start Producer:

```bash
bin/kafka-console-producer.sh \
--topic orders \
--bootstrap-server localhost:9092
```

Send Message:

```text
Order 1001 Created
Order 1002 Created
Order 1003 Created
```



# 9. Create Consumer

Open another terminal:

```bash
bin/kafka-console-consumer.sh \
--topic orders \
--from-beginning \
--bootstrap-server localhost:9092
```

Output:

```text
Order 1001 Created
Order 1002 Created
Order 1003 Created
```



# 10. Message Flow Explained

```text
Producer
   |
   V
Topic
   |
Partition
   |
Broker
   |
Consumer Group
   |
Consumer
```

Example:

```text
Order Service
     |
     V
 orders topic
     |
     V
 Payment Service
 Delivery Service
 Notification Service
```



# 11. Replication

Kafka replicates data.

Example:

```text
Partition-0

Leader -> Broker-1

Followers:
Broker-2
Broker-3
```

If Broker-1 crashes:

```text
Broker-2
becomes Leader
```

No data loss.



# 12. Real-Time Banking Example

Customer transfers money.

Event:

```json
{
  "transactionId": 1001,
  "amount": 5000
}
```

Kafka Topic:

```text
transactions
```

Consumers:

```text
Fraud Detection
Audit Service
Notification Service
Analytics Service
```

All process the same event independently.
