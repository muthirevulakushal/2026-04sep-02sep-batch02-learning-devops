# AWS EKS Persistent Storage Guide (StorageClass, PV, PVC, EBS & EFS)

## Overview

Kubernetes persistent storage consists of four key components:

```text
Application Pod
      │
      ▼
PersistentVolumeClaim (PVC)
      │
      ▼
PersistentVolume (PV)
      │
      ▼
StorageClass
      │
      ▼
AWS CSI Driver
      │
      ▼
AWS Storage (EBS / EFS / FSx)
```



# Core Kubernetes Storage Components

## 1. StorageClass

A StorageClass defines how storage should be dynamically provisioned.

It acts as a blueprint that tells Kubernetes:

* Which storage provider to use
* Storage type (gp3, io2, etc.)
* Reclaim behavior
* Volume binding strategy

### Example

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-gp3-sc

provisioner: ebs.csi.aws.com

parameters:
  type: gp3

reclaimPolicy: Delete

volumeBindingMode: WaitForFirstConsumer
```



## 2. PersistentVolume (PV)

A PersistentVolume is the actual storage resource available to the cluster.

Think of it as the physical disk or file system.

A PV can be:

* Created manually (Static Provisioning)
* Created automatically (Dynamic Provisioning)

### Example (Static PV)

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: app-pv

spec:
  capacity:
    storage: 10Gi

  accessModes:
    - ReadWriteOnce

  persistentVolumeReclaimPolicy: Retain

  storageClassName: manual

  hostPath:
    path: /data
```

### PV Lifecycle

```text
Available
    ↓
Bound
    ↓
Released
    ↓
Deleted / Retained
```



## 3. PersistentVolumeClaim (PVC)

A PVC is a request for storage made by an application.

The application never directly uses a PV.

Instead:

```text
Pod
 ↓
PVC
 ↓
PV
```

### Example

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc

spec:
  accessModes:
    - ReadWriteOnce

  resources:
    requests:
      storage: 10Gi

  storageClassName: ebs-gp3-sc
```



## 4. Pod

Applications consume storage through a PVC.

### Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx

spec:
  containers:
  - name: nginx
    image: nginx

    volumeMounts:
    - mountPath: /data
      name: storage

  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: app-pvc
```



# Static vs Dynamic Provisioning

## Static Provisioning

Administrator creates the PV manually.

```text
Admin Creates PV
       ↓
User Creates PVC
       ↓
PVC Binds to PV
       ↓
Pod Uses PVC
```

### Components

```text
PV (Manual)
     ↓
PVC
     ↓
Pod
```



## Dynamic Provisioning (Recommended)

Kubernetes automatically creates the PV when a PVC is requested.

```text
StorageClass
      ↓
PVC
      ↓
PV (Auto Created)
      ↓
Pod
```

### Components

```text
StorageClass
      ↓
PVC
      ↓
PV (Auto)
      ↓
Pod
```



# Access Modes

| Access Mode         | Description              |
| - |  |
| ReadWriteOnce (RWO) | Mounted by one node      |
| ReadOnlyMany (ROX)  | Read-only by many nodes  |
| ReadWriteMany (RWX) | Read/write by many nodes |



# AWS Storage Options

## Amazon EBS

### Best For

* PostgreSQL
* MySQL
* MongoDB
* Stateful Applications

### Access Mode

```yaml
ReadWriteOnce (RWO)
```

### Characteristics

| Feature             | EBS |
| - |  |
| Block Storage       | Yes |
| Shared Across Nodes | No  |
| Low Latency         | Yes |
| Database Workloads  | Yes |
| RWX Support         | No  |


Note:
eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster sigmaEKS-Cluster \
  --force \
  --region us-east-1

kubectl get pods -n kube-system | grep ebs
kubectl get sa ebs-csi-controller-sa \
-n kube-system -o yaml

aws eks describe-addon \
--cluster-name sigmaEKS-Cluster \
--addon-name aws-ebs-csi-driver \
--region us-east-1

aws eks describe-addon \
--cluster-name sigmaEKS-Cluster \
--addon-name aws-ebs-csi-driver \
--region us-east-1

aws eks describe-cluster \
--cluster-name sigmaEKS-Cluster \
--query "cluster.identity.oidc.issuer"

## Amazon EFS

### Best For

* Shared application files
* WordPress uploads
* CMS content
* AI/ML shared artifacts
* Multi-replica applications

### Access Mode

```yaml
ReadWriteMany (RWX)
```

### Characteristics

| Feature           | EFS |
| -- |  |
| Shared Storage    | Yes |
| Multi-node Access | Yes |
| RWX Support       | Yes |
| Regional Storage  | Yes |



# EBS Dynamic Provisioning Example

## StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-gp3-sc

provisioner: ebs.csi.aws.com

parameters:
  type: gp3
  fsType: ext4

allowVolumeExpansion: true

volumeBindingMode: WaitForFirstConsumer

reclaimPolicy: Delete
```



## PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc

spec:
  accessModes:
    - ReadWriteOnce

  storageClassName: ebs-gp3-sc

  resources:
    requests:
      storage: 10Gi
```



## Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-ebs

spec:
  containers:
  - name: nginx
    image: nginx

    volumeMounts:
    - mountPath: /data
      name: storage

  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: app-pvc
```



## Dynamic Provisioning Flow

```text
Create StorageClass
        ↓
Create PVC
        ↓
PVC Pending
        ↓
Create Pod
        ↓
AWS EBS CSI Driver
        ↓
EBS Volume Created
        ↓
PV Created
        ↓
PVC Bound
        ↓
Pod Running
```



# EFS Dynamic Provisioning Example

## StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc

provisioner: efs.csi.aws.com

parameters:
  provisioningMode: efs-ap
  fileSystemId: fs-xxxxxxxx

reclaimPolicy: Retain

volumeBindingMode: Immediate
```



## PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-pvc

spec:
  accessModes:
    - ReadWriteMany

  storageClassName: efs-sc

  resources:
    requests:
      storage: 5Gi
```



## Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-efs

spec:
  replicas: 3

  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx

    spec:
      containers:
      - name: nginx
        image: nginx

        volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: shared-storage

      volumes:
      - name: shared-storage
        persistentVolumeClaim:
          claimName: efs-pvc
```



# Why EBS Fails with Multiple Pods

## Problem

```text
Deployment (Replicas=3)
        │
        ▼
Single PVC
        │
        ▼
Single EBS Volume
```

Result:

```text
Pod-1 → Success
Pod-2 → Multi-Attach Error
Pod-3 → Multi-Attach Error
```

Error:

```text
Multi-Attach error for volume
Volume is already used by pod(s)
```

### Reason

EBS supports:

```yaml
ReadWriteOnce (RWO)
```

Only one node can attach the volume at a time.



# Correct Design Patterns

## Database Workloads

```text
StatefulSet
     │
 ┌───┼───┐
 │   │   │
 ▼   ▼   ▼

Pod-0 → EBS-0
Pod-1 → EBS-1
Pod-2 → EBS-2
```

Use:

```yaml
volumeClaimTemplates
```



## Shared Storage Workloads

```text
             Amazon EFS
                  │
      ┌───────────┼───────────┐
      │           │           │
    Pod-A       Pod-B       Pod-C
```

Use:

```yaml
ReadWriteMany (RWX)
```



# Reclaim Policies

## Delete

```yaml
reclaimPolicy: Delete
```

Behavior:

```text
PVC Deleted
    ↓
PV Deleted
    ↓
Storage Deleted
```



## Retain

```yaml
reclaimPolicy: Retain
```

Behavior:

```text
PVC Deleted
    ↓
PV Retained
    ↓
Storage Retained
```

Recommended for:

* Databases
* Critical Production Data



# Production Best Practices

## General

* Use dynamic provisioning.
* Use GP3 instead of GP2.
* Enable encryption.
* Monitor storage with CloudWatch.
* Use separate StorageClasses per workload.

## EBS

* Use StatefulSets.
* Use `WaitForFirstConsumer`.
* Use `Retain` for production databases.

## EFS

* Use Access Points.
* Enable AWS Backup.
* Create mount targets in all Availability Zones.
* Use RWX only when shared storage is required.



# Interview Questions

### What is the difference between PV and PVC?

| PV                              | PVC                         |
| - |  |
| Actual storage resource         | Request for storage         |
| Cluster-scoped object           | Namespace-scoped object     |
| Created manually or dynamically | Created by user/application |
| Supplies storage                | Consumes storage            |



### What is the difference between Static and Dynamic Provisioning?

| Static              | Dynamic                  |
| - |  |
| PV created manually | PV created automatically |
| More administration | Less administration      |
| Legacy approach     | Recommended approach     |



### Why is PVC in Pending state?

Common reasons:

* No matching PV available
* CSI driver not installed
* Incorrect StorageClass
* No worker nodes available
* Missing IAM permissions



### Why is PV not created immediately with EBS?

Because:

```yaml
volumeBindingMode: WaitForFirstConsumer
```

Kubernetes waits until a Pod is scheduled so it can create the EBS volume in the correct Availability Zone.



# Quick Memory Trick

```text
StorageClass = Blueprint
PV           = Actual Storage
PVC          = Storage Request
Pod          = Storage Consumer
CSI Driver   = Storage Provisioner
EBS/EFS      = AWS Storage Backend
```

## End-to-End Flow

```text
Pod
 ↓
PVC
 ↓
PV
 ↓
StorageClass
 ↓
AWS CSI Driver
 ↓
EBS / EFS
```