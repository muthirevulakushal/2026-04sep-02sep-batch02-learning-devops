#################################################################################################################################
 # DOCKER IMAGES BUILD
#################################################################################################################################

# DOCKER INSTALLATION
 $ sudo apt-get install docker.io -y
 $ docker --version

# DOCKER COMMANDS
 $ sudo su
 $ cd
 $ docker --version
 $ docker images
 $ docker ps -a
 $ git clone https://github.com/azonecloud/dkr-spring-boot.git
 $ cd cc-ion-src
 $ mvn clean package
 $ nano Dockerfile
   FROM tomcat
   EXPOSE 8080
   COPY /target/ion.war /usr/local/tomat/webapps/ion.war
 $ docker build . -t ionapp
 $ docker run -p 9090:8080 ionapp
 $ docker images
 $ docker rm <container-id>
 $ docker rmi -f <image-name/id>
 $ docker stop $(docker ps -aq)
 $ docker rm $(docker ps -aq)
 $ docker rmi $(docker images -q)

$ docker pull ssadcloud/myapp:latest
$ docker run -p 9090:8080 ssadcloud/myapp:latest


-------------------------------------------------------# LOCAL INSTALLATIONS # ------------------------------------------------

#################################################################################################################################
# INSTALLATIONS ON LOCAL SETUP
#################################################################################################################################

1. # KIND INSTALLATION ON WINDOWS
Key Page: https://kind.sigs.k8s.io/
          https://kind.sigs.k8s.io/docs/user/quick-start#installation


    $ curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.24.0/kind-windows-amd64

- Move kind-windows-amd64.exe to C:\kind\kind.exe
- SET Path = C:\kind

2. # KUBERENETES CLUSTER ON LOCAL MACHINE USING KIND
    $ kind create cluster --name main-k8s-cluster 

3. # KUBECTL INSTALLATION ON WINDOWS
    $ curl.exe -LO "https://dl.k8s.io/release/v1.31.0/bin/windows/amd64/kubectl.exe"

- Move kubectl.exe to C:\kind\kubectl.exe
- SET Path = C:\kubectl
    $ kubectl version

4.  # For Intel Macs
        $ [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-darwin-amd64
    # For M1 / ARM Macs
        $ [ $(uname -m) = arm64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-darwin-arm64
        $ chmod +x ./kind
        $ mv ./kind /usr/local/bin/kind

4. # KUBERNETS COMMANDS
    $ kind get clusters
    $ kubectl get nodes
    $ kubectl get pods
    $ kubectl get deploy
    $ kubectl describe deployment myapp-deployment

    $ kubectl apply -f manifests/myapp-deployment.yaml
    $ kubectl delete -f manifests/myapp-deployment.yaml

    $ kubectl exec --stdin --tty my-pod -- /bin/sh

# Port Forwarding
    $ kubectl port-forward svc/myapp-service-by-kumar 9090:9090

# ipconfig /all

# DOCKER COMMANDS:
    docker build -t ssadcloud/myapp:latest .
    docker push ssadcloud/myapp:latest
    docker pull ssadcloud/myapp:latest
    docker run -p 8080:8080 ssadcloud/myapp:latest

# HELM INSTALLATION:
Key Page: 
# Download:
    https://helm.sh/docs/intro/install/

# Assets
    https://github.com/helm/helm/releases/tag/v3.16.3

# FOR Ubuntu
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm

# PROMETHEOUS INSTALLATION USING HELM CHARTS
```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install main-prometheous-release prometheus-community/prometheus
```

-- For Prometheous Server
# main-prometheous-release-prometheus-server.default.svc.cluster.local
NAME: my-prometheus
LAST DEPLOYED: Wed Sep  2 12:25:55 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
my-prometheus-server.default.svc.cluster.local


Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=my-prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9090

Prometheus alertmanager can be accessed via port 9093 on the following DNS name from within your cluster:
my-prometheus-alertmanager.default.svc.cluster.local


Get the Alertmanager URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=alertmanager,app.kubernetes.io/instance=my-prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9093

Prometheus Pushgateway can be accessed via port 9091 on the following DNS name from within your cluster:
my-prometheus-prometheus-pushgateway.default.svc.cluster.local


Get the Pushgateway URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus-pushgateway,app.kubernetes.io/instance=my-prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9091

For more information on running Prometheus, visit:
https://prometheus.io/
```

## GRAFANA INSTALLATION USING HELM CHARTS
```bash
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update

    helm install main-grafana-release grafana/grafana


1. Get your 'admin' user password by running:
   kubectl get secret --namespace default main-grafana-release -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    JS5cDavhbehwlVuXJzy2l2attHUs8NgCfniGHZTZ

2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:
   main-grafana-release.default.svc.cluster.local

   Get the Grafana URL to visit by running these commands in the same shell:
     export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=main-grafana-release" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace default port-forward $POD_NAME 3000

3. Login with the password from step 1 and the username: admin
#################################################################################
######   WARNING: Persistence is disabled!!! You will lose your data when   #####
######            the Grafana pod is terminated.                            #####
#################################################################################
```

# PROMETHEOUS UNINSTALLAITON
helm uninstall main-prometheous-release

# GRAFANA UNINSTALLAITON
helm uninstall main-grafana-release


# FOR PROMETHEUS
Node Exporter (Windows)
https://github.com/prometheus-community/windows_exporter/releases


Node Exporter(Linux)
https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.darwin-amd64.tar.gz

#################################################################################################################################
# INSTALLATION FOR AWS EC2 
#################################################################################################################################
# SSH CONNECT TO MAIN K8S INSTANCE
1. # ssh -i "k8s.pem" ubuntu@<<public-dns>>

2. # After connecting to Machince,
   $ sudo su
   $ cd
   $ mkdir <<name>>
   $ cd <<name>>

3. # Version Control System - GIT
    Key page: https://git-scm.com/download/linux

    $ sudo apt-get install git -y
    $ git --version

4. # Build Tool - JDK - Java and Maven
   $ sudo apt-get update
   $ sudo apt-get install openjdk-17-jdk -y
   $ ls /usr/lib/jvm/
   $ nano ~/.bashrc
   ```bash
      export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
      export PATH=$JAVA_HOME/bin:$PATH
   ```
   $ source ~/.bashrc
   $ echo $JAVA_HOME
   $ which java

   $ sudo apt-get install maven -y   # Maven Installation
   $ mvn --version

5.  # JENKINS INSTALLAITON
    https://pkg.jenkins.io/debian-stable/

    $   sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

    $   echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

    $   sudo apt-get update
    $   sudo apt-get install fontconfig openjdk-17-jre
    $   sudo apt-get install jenkins
    $   cat /var/lib/jenkins/secrets/initialAdminPassword

6. # Programmatically Create Resources in AWS : (Commands) - AWS Command Line Interface
   Key Pages: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#cliv2-linux-install

```bash
   $ aws --version
   $ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   $ apt-get install unzip -y
   $ unzip awscliv2.zip
   $ sudo ./aws/install
```

7. # FOR AWS EC2 DOCKER INSTALLATION
    # For Ubuntu(debian)
```bash
    $ sudo su
    cd
    apt-get update -y
    apt-get install docker.io -y

    # For Amazon Linux(yum repos)
    sudo su
    cd
    yum install docker -y
    docker pull ssadcloud/myapp:latest
    docker run ssadcloud/myapp:latest
```
8. # KUBECTL INSTALLATION ON AWS UBUNTU LINUX MACHINE
```bash 
    $ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    $ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
9. # TERRAFORM AS IAC 
```bash
    $ wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    $ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    $ sudo apt update && sudo apt install terraform
```
10. # EKSCTL INSTALLATION
```bash
   $ curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
   $ sudo mv /tmp/eksctl /usr/local/bin
   $ eksctl version
   $ eksctl create cluster --name sigmaEKS-Cluster --region us-east-2 --nodegroup-name sigmaEKS-Cluster-NG --node-type t2.micro --nodes 2 --nodes-min 2 --nodes-max 5 --ssh-access --ssh-public-key kp --managed
```
################################################################################################
# CI/CD RELEASE JENKINS INTEGRATION 
################################################################################################
A. Build Source Code ( Using Jenkins)
     $ clean package

B. Push Images to DOCKER HUB
```bash
   sudo docker build -t <<name-of-docker-hub>>\myapp .
   sudo docker push <<name-of-docker-hub>>\myapp:latest
```

C. Push Images to AWS ECR
```bash
    sudo aws ecr get-login-password --region us-east-2 | sudo docker login --username AWS --password-stdin 932589472370.dkr.ecr.us-east-2.amazonaws.com
    sudo docker build -t myapp-ecr .
    sudo docker tag myapp-ecr:latest 932589472370.dkr.ecr.us-east-2.amazonaws.com/myapp-ecr:latest
    sudo docker push 932589472370.dkr.ecr.us-east-2.amazonaws.com/myapp-ecr:latest
```
D. For Deployment 
  # Delete Previous Deployment/Services
    $ sudo kubectl delete -f manifests/myapp-service.yaml
    $ sudo kubectl delete -f manifests/myapp-deployment.yaml

  # Create Deployments and Services
    $ sudo kubectl apply -f manifests/myapp-deployment.yaml
    $ sudo kubectl apply -f manifests/myapp-service.yaml

E. GITHUB and JENKINS WEBHOOK:
Use when you want to trigger JENKINS job upon commits to GitHub Repo

   $ http://<<public-ip or public-dns-jenkins>>8080/github-webhook/

F. Grant Jenkins sudo previlages
    $ sudo nano /etc/sudoers
    ## Now add the below lines in your sudoers file :
    jenkins ALL=(ALL) NOPASSWD: ALL
   
################################################################################################
# PROVISIONING AWS EKS CLUSTER USING TERRAFORM
################################################################################################
# https://grafana.com/docs/grafana-cloud/monitor-infrastructure/kubernetes-monitoring/configuration/config-other-methods/config-aws-eks/

```bash
    $ brew install awscli
    $ brew install eksctl
    $ terraform init
    $ terraform plan
    $ terraform apply --auto-approve
    $ aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
    $ aws eks create-addon --cluster-name ${CLUSTER_NAME} --region ${CLUSTER_REGION} --addon-name grafana-labs_kubernetes-monitoring

cluster_endpoint = "https://0048A68314A14E6BA97275A209264A21.gr7.us-east-2.eks.amazonaws.com"
cluster_name = "main-eks-TJNwdVJi"
cluster_security_group_id = "sg-0a96de416f8ecd238"
region = "us-east-2"

# Note: 0.10 USD per Hour Cost for running this EKS Cluster
```


aws eks --region "us-east-2" update-kubeconfig --name "main-eks-TJNwdVJi"