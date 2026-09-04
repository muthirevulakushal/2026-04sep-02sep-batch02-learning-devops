# Kubernetes Ingress End-to-End Setup (Orders & Payments)
## Overview
This document provides a complete working setup for:
    * Deployments (orders & payments)
    * Services (ClusterIP)
    * Ingress (path-based routing)

### Routing :
```
/orders   → orders-service
/payments → payments-service
```
# Deployments
## Orders Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orders-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: orders
  template:
    metadata:
      labels:
        app: orders
    spec:
      containers:
      - name: orders-container
        image: ssadcloud/orders:latest
        ports:
          - containerPort: 8080
```


## Payments Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payments-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: payments
  template:
    metadata:
      labels:
        app: payments
    spec:
      containers:
      - name: payments-container
        image: ssadcloud/payments:latest
        ports:
          - containerPort: 8080
```

# Services
## Orders Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: orders-service
spec:
  selector:
    app: orders
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP
```

## Payments Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: payments-service
spec:
  selector:
    app: payments
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP
```

# Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: myapp-ingress.localhost
      http:
        paths:
          - path: /orders
            pathType: Prefix
            backend:
              service:
                name: orders-service
                port:
                  number: 8080
          - path: /payments
            pathType: Prefix
            backend:
              service:
                name: payments-service
                port:
                  number: 8080
```
# Install Ingress Controller (NGINX)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

Verify:

```bash
kubectl get pods -n ingress-nginx
expected outcome:
```output
ingress-nginx-admission-create-scvgm        0/1     Completed   0          15h
ingress-nginx-admission-patch-ldx5b         0/1     Completed   0          15h
ingress-nginx-controller-7d65c586d6-qktzr   1/1     Running     0          15s
```
```


# Apply All Resources
```bash
kubectl apply -f deployments.yaml
kubectl apply -f services.yaml
kubectl apply -f ingress.yaml
```

# Update Hosts File
Add this line:
nano /etc/hosts (Linux)
C:\Windows\System32\drivers\etc\hosts (Windows)
```
127.0.0.1 myapp-ingress.localhost
127.0.0.1 myapp.example.com
```
# Port Forward Ingress Controller
```bash
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
```

# Testing
## Orders API
```bash
curl http://myapp-ingress.localhost:8080/orders
```
## Payments API
```bash
curl http://myapp-ingress.localhost:8080/payments
```
# Expected Output
```
Orders Service
Payments Service
```


# Architecture Flow
```
User → Host (myapp-ingress.localhost)
      ↓
Ingress Controller (NGINX)
      ↓
Ingress Rules
      ↓
Service (ClusterIP)
      ↓
Pods (Orders / Payments)
```

# Troubleshooting
### Check Pods
```bash
kubectl get pods -n myapp
```

### Check Services
```bash
kubectl get svc -n myapp
```

### Check Ingress
```bash
kubectl describe ingress -n myapp
```

### Check Endpoints
```bash
kubectl get endpoints -n myapp
```


$ curl --resolve "hello-world.info:80:$( minikube ip )" -i http://hello-world.info/orders
$ curl --resolve "hello-world.info:80:$( minikube ip )" -i http://hello-world.info/payments
