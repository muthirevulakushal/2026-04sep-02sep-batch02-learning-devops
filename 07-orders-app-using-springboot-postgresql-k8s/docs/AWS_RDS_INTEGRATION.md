# AWS RDS PostgreSQL Integration Guide

This guide provides step-by-step instructions for integrating AWS RDS PostgreSQL with your Spring Boot Order Service.

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Kubernetes cluster with IAM roles attached
- kubectl configured

## Step 1: Create AWS RDS PostgreSQL Instance

### Using AWS Console

1. Navigate to RDS > Databases > Create Database
2. Choose PostgreSQL engine
3. Select version 16 or latest
4. Set Database Instance Class (e.g., db.t3.micro for dev/test)
5. Set Master Username: `postgres`
6. Set Master Password (save securely)
7. Configure VPC and Security Group
8. Enable automated backups
9. Set backup retention (7-30 days)
10. Create database

### Using AWS CLI

```bash
aws rds create-db-instance \
  --db-instance-identifier order-service-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 16.3 \
  --master-username postgres \
  --master-user-password your-secure-password-here \
  --allocated-storage 20 \
  --storage-type gp3 \
  --publicly-accessible false \
  --vpc-security-group-ids sg-xxxxxxxxx \
  --db-subnet-group-name default \
  --backup-retention-period 7 \
  --multi-az false \
  --enable-cloudwatch-logs-exports postgresql \
  --tags Key=Environment,Value=Development Key=Application,Value=OrderService
```

### Using Terraform

```hcl
resource "aws_db_instance" "order_service" {
  identifier     = "order-service-db"
  engine         = "postgres"
  engine_version = "16.3"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type      = "gp3"
  
  db_name  = "orders"
  username = "postgres"
  password = var.db_password
  
  skip_final_snapshot = false
  final_snapshot_identifier = "order-service-final-snapshot-${timestamp()}"
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  
  publicly_accessible = false
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  
  enable_cloudwatch_logs_exports = ["postgresql"]
  
  tags = {
    Name        = "order-service-db"
    Environment = "development"
    Application = "order-service"
  }
}
```

## Step 2: Retrieve RDS Endpoint

```bash
# Get RDS endpoint
aws rds describe-db-instances \
  --db-instance-identifier order-service-db \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text

# Result example: order-service-db.czxxxxxx.us-east-1.rds.amazonaws.com
```

## Step 3: Configure Security Group

### Allow Inbound PostgreSQL Traffic

```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxxx \
  --protocol tcp \
  --port 5432 \
  --source-security-group-id sg-k8s-nodes-sg
```

### Or using AWS Console

1. Go to RDS > Databases > order-service-db
2. Click on Security Group
3. Edit inbound rules
4. Add rule:
   - Type: PostgreSQL
   - Protocol: TCP
   - Port: 5432
   - Source: Security group of K8s nodes

## Step 4: Initialize Database

### Create Order Service Database and User

```bash
# Get temporary password or use master password
psql -h order-service-db.czxxxxxx.us-east-1.rds.amazonaws.com \
     -U postgres \
     -d postgres

# In psql console:
CREATE DATABASE orders;
CREATE USER order_service WITH ENCRYPTED PASSWORD 'secure-password';
GRANT ALL PRIVILEGES ON DATABASE orders TO order_service;
\c orders
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO order_service;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO order_service;
```

### Using SQL Script

```sql
CREATE DATABASE orders;
CREATE USER order_service WITH ENCRYPTED PASSWORD 'secure-password';
ALTER ROLE order_service SET client_encoding TO 'utf8';
ALTER ROLE order_service SET default_transaction_isolation TO 'read committed';
ALTER ROLE order_service SET default_transaction_deferrable TO on;
ALTER ROLE order_service SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE orders TO order_service;
\c orders
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO order_service;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO order_service;
```

## Step 5: Update Kubernetes Configuration

### Update ConfigMap (k8s/02-configmap.yaml)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: order-service-config
  namespace: order-service
data:
  # RDS PostgreSQL Configuration
  DB_HOST: "order-service-db.czxxxxxx.us-east-1.rds.amazonaws.com"
  DB_PORT: "5432"
  DB_NAME: "orders"
  DB_POOL_MAX_SIZE: "20"
  DB_POOL_MIN_IDLE: "5"
  
  # JPA Configuration (use 'validate' for production)
  JPA_DDL_AUTO: "validate"
  
  # Other configurations...
```

### Update Secret (k8s/03-secret.yaml)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: order-service-secret
  namespace: order-service
type: Opaque
stringData:
  DB_USER: order_service
  DB_PASSWORD: your-secure-password-here
  AWS_REGION: us-east-1
```

## Step 6: IAM Authentication (Recommended for Production)

### Create IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": [
        "arn:aws:rds:us-east-1:ACCOUNT_ID:db:order-service-db"
      ]
    }
  ]
}
```

### Create IAM Role for K8s Service Account

```bash
# Create role trust policy
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/OIDC_PROVIDER"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "OIDC_PROVIDER:sub": "system:serviceaccount:order-service:order-service"
        }
      }
    }
  ]
}
EOF

# Create role
aws iam create-role \
  --role-name OrderServiceRDSRole \
  --assume-role-policy-document file://trust-policy.json

# Attach policy
aws iam put-role-policy \
  --role-name OrderServiceRDSRole \
  --policy-name RDSConnect \
  --policy-document file://rds-policy.json
```

### Annotate K8s Service Account

```bash
kubectl annotate serviceaccount order-service \
  -n order-service \
  eks.amazonaws.com/role-arn=arn:aws:iam::ACCOUNT_ID:role/OrderServiceRDSRole
```

## Step 7: Deploy to Kubernetes

```bash
# Apply configurations
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secret.yaml

# Deploy application (without PostgreSQL pod)
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/05-order-service-deployment.yaml
kubectl apply -f k8s/06-hpa.yaml

# Verify deployment
kubectl get pods -n order-service
kubectl logs -f deployment/order-service -n order-service
```

## Step 8: Database Migrations

### Initial Schema Creation

The application uses JPA with `ddl-auto: validate`. For production, manually manage schema:

```bash
# Connect to RDS
psql -h order-service-db.czxxxxxx.us-east-1.rds.amazonaws.com \
     -U order_service \
     -d orders

# Create initial schema (if not auto-created)
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(100) UNIQUE NOT NULL,
    customer_id VARCHAR(100) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    shipping_address TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    payment_status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    shipping_address VARCHAR(500),
    notes VARCHAR(1000)
);

CREATE INDEX idx_order_id ON orders(id);
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_status ON orders(status);
```

### Using Liquibase/Flyway

For version control of schema changes, use Liquibase or Flyway:

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.liquibase</groupId>
    <artifactId>liquibase-core</artifactId>
</dependency>
```

## Step 9: Backup Strategy

### Automated Backups

RDS automatically creates daily backups. Configure:

```bash
# Set backup retention
aws rds modify-db-instance \
  --db-instance-identifier order-service-db \
  --backup-retention-period 30 \
  --preferred-backup-window "03:00-04:00" \
  --apply-immediately
```

### Manual Backup

```bash
# Create manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier order-service-db \
  --db-snapshot-identifier order-service-backup-$(date +%Y%m%d)

# List snapshots
aws rds describe-db-snapshots \
  --db-instance-identifier order-service-db
```

### Export Backup

```bash
# Export to S3
aws rds start-export-task \
  --export-task-identifier order-service-export-$(date +%Y%m%d) \
  --source-arn arn:aws:rds:us-east-1:ACCOUNT_ID:snapshot:order-service-backup \
  --s3-bucket-name my-backup-bucket \
  --s3-prefix order-service/ \
  --iam-role-arn arn:aws:iam::ACCOUNT_ID:role/RDSExportRole
```

## Step 10: Monitoring

### CloudWatch Metrics

```bash
# View CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=order-service-db \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

### Enable Enhanced Monitoring

```bash
aws rds modify-db-instance \
  --db-instance-identifier order-service-db \
  --enable-cloudwatch-logs-exports postgresql \
  --apply-immediately
```

## Troubleshooting

### Connection Issues

```bash
# Test connectivity
telnet order-service-db.czxxxxxx.us-east-1.rds.amazonaws.com 5432

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids sg-xxxxxxxxx \
  --query 'SecurityGroups[0].IpPermissions'

# Check K8s pod network connectivity
kubectl exec -it pod/order-service-xxxxx -n order-service \
  -- nc -zv order-service-db.czxxxxxx.us-east-1.rds.amazonaws.com 5432
```

### Performance Issues

```bash
# Check active connections
psql -h order-service-db.czxxxxxx.us-east-1.rds.amazonaws.com \
     -U postgres \
     -d orders \
     -c "SELECT count(*) FROM pg_stat_activity;"

# Check slow queries
psql -h order-service-db.czxxxxxx.us-east-1.rds.amazonaws.com \
     -U postgres \
     -d orders \
     -c "SELECT query, calls, total_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

## Cost Optimization

1. **Right-size instance** - Start with db.t3.micro, scale up as needed
2. **Use Reserved Instances** - For production, purchase 1-3 year reserved capacity
3. **Enable automated backups** - Don't create unnecessary manual snapshots
4. **Use storage autoscaling** - Enable automatic storage expansion
5. **Monitor unused resources** - Check for unused databases

## Production Checklist

- [ ] RDS instance created with Multi-AZ
- [ ] Automated backups configured (7-30 days)
- [ ] Security group properly configured
- [ ] IAM authentication enabled
- [ ] Enhanced monitoring enabled
- [ ] CloudWatch alarms configured
- [ ] Parameter group optimized
- [ ] Database encryption enabled
- [ ] SSL/TLS enforced
- [ ] Backup retention policy defined
- [ ] Disaster recovery plan documented
- [ ] Performance baseline established

## References

- [AWS RDS PostgreSQL Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [PostgreSQL Security Best Practices](https://www.postgresql.org/docs/current/sql-security.html)
- [Spring Boot RDS Integration](https://spring.io/guides/gs/accessing-data-jpa/)
