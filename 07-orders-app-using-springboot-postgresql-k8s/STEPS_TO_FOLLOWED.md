## AWS Order Service
A production-ready Spring Boot microservice for managing orders with PostgreSQL and Apache Kafka integration.
Fully containerized and ready for Kubernetes deployment.

## Features
- Spring Boot 3.4.4 - Latest Spring Boot framework
- PostgreSQL 16 - AWS RDS compatible relational database
- Apache Kafka 7.7 - Event-driven order processing
- Thymeleaf Templates - Modern HTML UI for order management
- REST API - Complete REST endpoints for order operations
- Docker & Kubernetes - Production-ready containerization
- Health Checks - Liveness and readiness probes
- Actuator Endpoints - Metrics and monitoring
- Environment-based Configuration - .env support for all variables
- Auto-scaling - Horizontal Pod Autoscaler (HPA) ready

## Project Structure

```
orders-app-using-springboot-postgresql/
├── order-service/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/de/example
│   │   │   │   ├── config/
                     └── KafkaConfig.java
│   │   │   │   └── controller/
│   │   │   │   │    └── OrderController.java (REST API)
│   │   │   │   ├── model/
                     └──Order.java
│   │   │   │   ├── dto/
│   │   │   │   │    └── PaymentRequest.java
│   │   │   │   ├── events/
│   │   │   │   │    ├── OrderCreatedEvent.java
│   │   │   │   │    └── PaymentApprovedEvent.java
│   │   │   │   │    ├── PaymentFailedEvent.java
│   │   │   │   │    └── PaymentResultsEvent.java
│   │   │   │   ├── model/
│   │   │   │   │    ├── Order.java
│   │   │   │   ├── repository/
│   │   │   │   │    ├── OrderRepository.java
│   │   │   │   ├── service/
│   │   │   │   │    ├── KafkaMessageListener.java
│   │   │   │   │    ├── OrderService.java
│   │   │   │   │    └── PaymentMock.java
│   │   │   │   ├── OrderApplication.java


│   │   │   └── resources/
│   │   │       ├── application.yaml
│   ├── pom.xml
│   └── Dockerfile
├── k8s/
│   ├── 01-namespace.yaml
│   ├── 02-configmap.yaml
│   ├── 03-secret.yaml
│   ├── 04-order-service-deployment.yaml
│   ├── 05-hpa.yaml
├── docker-compose.yaml
├── .env
├── .env.example
├── Dockerfile
└── README.md
```

## Quick Start

### Prerequisites

- Java 17+
- Maven 3.9+
- Docker & Docker Compose
- Kubernetes cluster (optional)
- PostgreSQL 16 (or use Docker)
- Apache Kafka 7.7 (or use Docker)

### Local Development with Docker Compose

```bash
# Clone and navigate to project
cd orders-app-using-springboot-postgresql

# Start all services
docker-compose up -d

# Access the application
# Web UI: http://localhost:8080
# Health: http://localhost:8080/actuator/health
# REST API: http://localhost:8080/api/orders

# View logs
docker-compose logs -f order-service

# Stop services
docker-compose down -v
```

### Build and Run Locally

```bash
# Build the application
cd cd orders-app-using-springboot-postgresql
mvn clean package

# Run the application
java -jar target/order-service-1.0.0.jar

# Access at http://localhost:8080
```

## Docker

### Build Image

```bash
docker build -t order-service .
docker tag order-service:latest ssadcloud/order-service:latest
```
### Push Image

```bash
docker push ssadcloud/order-service:latest
```

### Run Container

```bash
docker run -it --rm \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_NAME=orders \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres \
  -e KAFKA_BOOTSTRAP_SERVERS=host.docker.internal:9092 \
  -p 8080:8080 \
  ssadcloud/order-service:latest
```

## Kubernetes Deployment

### Prerequisites

- kubectl configured
- Docker image pushed to registry
- Kubernetes 1.24+

### Deploy

```bash
# 1. Create namespace
kubectl apply -f k8s/01-namespace.yaml

# 2. Create ConfigMap
kubectl apply -f k8s/02-configmap.yaml

# 3. Create Secrets (update with your credentials)
kubectl apply -f k8s/03-secret.yaml

# 4. Deploy Order Service (update image name first)
kubectl apply -f k8s/04-order-service-deployment.yaml

# 7. Deploy HPA
kubectl apply -f k8s/05-hpa.yaml

### Verify Deployment

```bash
# Check pods
kubectl get pods -n order-service

# Check services
kubectl get svc -n order-service

# Port forward
kubectl port-forward -n order-service svc/order-service 8080:8080

# Access at http://localhost:8080
```

## API Endpoints

### REST API

#### Create Order

```bash
POST /orders/
Content-Type: application/json

{
  "customerId": "CUST-001",
  "amount":100
}
```

#### Get Order

```bash
GET /orders/{orderId}/Status
```


## Environment Variables

### Database Configuration

```env
# =========================
# Database (PostgreSQL)
# =========================
#DB_HOST=host.docker.internal
DB_HOST=host.minikube.internal
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=MainPassword1%
DB_POOL_MAX_SIZE=20
DB_POOL_MIN_IDLE=5

#KAFKA_BOOTSTRAP_SERVERS=kafka:9092
KAFKA_BOOTSTRAP_SERVERS=kafka-service.order-service.svc.cluster.local:9092
KAFKA_CONSUMER_GROUP=order-service-group
KAFKA_AUTO_OFFSET_RESET=earliest

KAFKA_TOPIC_ORDERS=order-events
KAFKA_TOPIC_PAYMENTS=payment-events

# =========================
# Spring-compatible datasource (recommended for consistency)
# =========================
SPRING_DATASOURCE_URL=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
SPRING_DATASOURCE_USERNAME=${DB_NAME}
SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}

# =========================
# Kafka Configuration
# =========================
# IMPORTANT: used by Spring Boot auto-config only
SPRING_KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS}
SPRING_KAFKA_CONSUMER_GROUP_ID=${KAFKA_CONSUMER_GROUP}

# =========================
# Server Configuration
# =========================
SERVER_PORT=8080

# =========================
# JPA / Hibernate
# =========================
JPA_DDL_AUTO=validate

# =========================
# Logging
# =========================
LOG_LEVEL=INFO

# =========================
# Management / Actuator
# =========================
MANAGEMENT_HEALTH_DETAILS=always

# =========================
# AWS Configuration
# =========================
AWS_REGION=us-east-1

# =========================
# Tomcat
# =========================
TOMCAT_MAX_THREADS=200
TOMCAT_MIN_SPARE=10

```

## Database Schema

### Orders Table

```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    customer_id VARCHAR(255) NOT NULL,
    amount FLOAT NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP
);

SELECT * FROM orders;
DROP TABLE orders;
```

## Event Flow

```
1. User submits order via UI/REST API
   ↓
2. Order created in PostgreSQL
   ↓
3. OrderCreatedEvent published to Kafka
   ↓
4. PaymentService processes payment async
   ↓
5. PaymentProcessedEvent published to Kafka
   ↓
6. Order status updated (CONFIRMED or CANCELLED)
   ↓
7. Event consumed and logged
```

## Security Features

- Containerized with non-root user (spring:1000)
- Read-only filesystem for sensitive paths
- RBAC configured in Kubernetes
- Secrets managed via ConfigMap and Secret objects
- Resource quotas and limits enforced
- PodDisruptionBudget for high availability
- Network policies ready for implementation

## Monitoring

### Health Endpoints

- `/actuator/health` - Overall health
- `/actuator/health/liveness` - Pod liveness
- `/actuator/health/readiness` - Pod readiness
- `/actuator/metrics` - Prometheus metrics
- `/actuator/prometheus` - Prometheus scrape endpoint

### Kubernetes Monitoring
```bash
# HPA status
kubectl get hpa -n order-service -w

# Resource usage
kubectl top pods -n order-service
kubectl top nodes

# Events
kubectl get events -n order-service
```

## Scaling
### Manual Scaling

```bash
kubectl scale deployment order-service -n order-service --replicas=5
```

### Automatic Scaling

HPA is configured with:
- Min replicas: 2
- Max replicas: 10
- CPU target: 70%
- Memory target: 80%

## Backup & Restore
### PostgreSQL Backup

```bash
# Backup
kubectl exec -n order-service $(kubectl get pod -l app=postgres -n order-service -o jsonpath='{.items[0].metadata.name}') \
  -- pg_dump -U postgres orders > backup.sql

# Restore
kubectl exec -i -n order-service $(kubectl get pod -l app=postgres -n order-service -o jsonpath='{.items[0].metadata.name}') \
  -- psql -U postgres orders < backup.sql
```

## Troubleshooting
### Common Issues
1. Database connection failed
   - Check DB_HOST and DB_PORT
   - Verify PostgreSQL pod is running
   - Check network policies

2. Kafka connection issues
   - Verify Kafka broker is running
   - Check KAFKA_BOOTSTRAP_SERVERS
   - Ensure topics are created

3. Pod CrashLoopBackOff
   - Check logs: `kubectl logs -n order-service <pod-name>`
   - Verify resources are available
   - Check environment variables

## Documentation
- [Kubernetes Deployment Guide](KUBERNETES_DEPLOYMENT_GUIDE.md)
- [API Documentation](swagger-ui.html) - Available at `/swagger-ui.html`
- [Application Configuration](order-service/src/main/resources/application.yaml)

## Testing

```bash
# Run tests
mvn test

# Run with coverage
mvn test jacoco:report

# Integration tests
mvn verify
```

## Production Deployment
For production deployment:
1. Use AWS RDS PostgreSQL instead of in-cluster database
2. Configure proper SSL/TLS certificates
3. Setup monitoring with Prometheus and Grafana
4. Implement CI/CD pipeline (GitHub Actions, Jenkins, etc.)
5. Configure log aggregation (ELK, CloudWatch)
6. Implement proper backup strategy
7. Setup autoscaling based on metrics
8. Configure network policies
9. Implement rate limiting and API gateway

## License
MIT License

## Support
For issues or questions, please:
1. Check the troubleshooting section
2. Review application logs
3. Check Kubernetes documentation
4. Create an issue in the repository

## Learning Resources
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)