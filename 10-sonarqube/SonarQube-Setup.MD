====================================================================================
#1. SonarQube Documentation
====================================================================================
KeyPages:
https://docs.sonarqube.org/latest/setup/get-started-2-minutes/
https://docs.sonarqube.org/latest/
https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/

====================================================================================
#2. What is SonarQube ?
====================================================================================
-- SonarQube® is an automatic code review tool to detect bugs,
   vulnerabilities and code smells in your code.
-- It can integrate with your existing workflow
-- Enables for continuous code inspection across your project branches and pull requests

====================================================================================
#3. How to Setup SonarQube ?
====================================================================================

==========================================================================
Prerequisites:
==========================================================================
  - An EC2 instance with Min of 4 GB of RAM ,t2.small is recommended[ SonarQube require a min of 4 GB of RAM]
  -	An EC2 Instance with latest Ubuntu OS
  - PostgreSQL Version 9.3 or higher
	- Security Groups with Port opened for 9000,to run JENKINS (default port 8080) and SonarQube at 9000
	- Git CLI to be installed on Ubuntu to pull the code from GitHub
	- Java JDK to be installed on Ubuntu instance for running the java code
	- Maven to be installed on Ubuntu instance for compile/build java-maven project
	- Jenkins to be installed on Ubuntu instance
	- In Jenkins, update Home for MAVEN=/usr/local/bin/maven/
	- Create a user "jenkins" with sudo privilege's
=====================================================================================
#4. Learning about Installation of SonarQube on Ubuntu 20.04
=====================================================================================
- We are installing SonarQube 7.9.3 version and have to install Oracle JAVA/Open JDK
- Postgres/MS-SQL as database and Latest browser before installing SonarQube
- Increase the vm.max_map_count kernal ,file discriptor and ulimit for current session at runtime.

   $ sudo sysctl -w vm.max_map_count=262144
   $ sudo sysctl -w fs.file-max=65536
   $ ulimit -n 65536
   $ ulimit -u 4096

To Increase the vm.max_map_count kernal ,file discriptor and ulimit permanently .
Open the below config file and Insert the below value as shown below,

   $ sudo nano /etc/security/limits.conf
     ++ sonarqube   -   nofile   65536
     ++ sonarqube   -   nproc    4096

==========================================================================
#4.1) GIT INSTALLATION ON UBUNTU LINUX
==========================================================================
	$ sudo su
	$ cd
	$ sudo apt-get update -y
	$ sudo apt-get install git -y
	$ git --version

==========================================================================
#4.2) JAVA INSTALLATION on UBUNTU LINUX
==========================================================================
	$ sudo su
	$ cd
	$ sudo apt-get update -y
	$ sudo apt install openjdk-11-jdk -y
	$ java -version
	$ export JAVA_HOME='/usr/lib/jvm/java-1.11.0-openjdk-amd64'

==========================================================================
#4.3) MAVEN INSTALLATION on UBUNTU LINUX
==========================================================================
	$ sudo su
	$ cd
	$ sudo apt-get update -y
	$ sudo apt-get install unzip -y
	$ wget http://apachemirror.wuchna.com/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.zip
	$ unzip apache-maven-3.6.3-bin.zip
	$ mv apache-maven-3.6.3 maven
	$ mv maven/ /usr/local/bin/
	$ export M2_HOME=/usr/local/bin/maven/
	$ export PATH=$PATH:/usr/local/bin/maven/bin/
	$ mvn --version

==========================================================================
#4.4) JENKINS INSTALLATION ON AWS EC2 Ubuntu instances
==========================================================================
KeyPages:		https://www.jenkins.io/doc/book/installing/#debianubuntu

	$ wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
	$ sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
	$ sudo apt-get update -y
	$ sudo apt-get upgrade -y
	$ sudo apt-get install jenkins -y
	$ systemctl status jenkins.service

 #To retrieve the Initial password
	$ sudo vi /var/lib/jenkins/secrets/initialAdminPassword
==========================================================================
#4.5) SonarQube INSTALLATION ON AWS EC2 Ubuntu instances
==========================================================================
Before installing, Lets update and upgrade System Packages
  $ sudo apt-get update
  $ sudo apt-get upgrade
  $ sudo apt-get install wget unzip -y
==========================================================================
#4.6) Install and Setup PostgreSQL 10 Database For SonarQube
==========================================================================
  $ sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
  $ wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
  $ sudo apt-get -y install postgresql postgresql-contrib
  $ sudo systemctl start postgresql
  $ sudo systemctl enable postgresql
  $ sudo passwd postgres
  $ su - postgres
  $ createuser sonar
  $ psql
  $ ALTER USER sonar WITH ENCRYPTED password 'sonar';
  $ CREATE DATABASE sonarqube OWNER sonar;
  $ grant all privileges on DATABASE sonarqube to sonar;
  $ \q
  $ exit
==========================================================================
#4.7) Install and Setup SONARQUBE
==========================================================================  
  Download sonaqube installer files archieve To download latest version of visit SonarQube download page.
  $ cd /tmp
  $ sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.9.3.zip
  $ sudo unzip sonarqube-7.9.3.zip -d /opt

  Move extracted setup to /opt/sonarqube directory
  $ sudo mv /opt/sonarqube-7.9.3 /opt/sonarqube

==========================================================================
#4.8) Configure SonarQube
==========================================================================
We can’t run Sonarqube as a root user , if you run using root user it stops automatically.
We have found solution on this to create separate group and user to run sonarqube.

  Create Group and User:
  Create a group as sonar
  $ sudo groupadd sonar

  Now add the user with directory access
  $ sudo useradd -c "user to run SonarQube" -d /opt/sonarqube -g sonar sonar
  $ sudo chown sonar:sonar /opt/sonarqube -R

  Open the SonarQube configuration file using your favorite text editor.
  $ sudo nano /opt/sonarqube/conf/sonar.properties
      + sonar.jdbc.username=sonar
      + sonar.jdbc.password=sonar
      + sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube  

  Edit the sonar script file and set RUN_AS_USER
  $ sudo nano /opt/sonarqube/bin/linux-x86-64/sonar.sh
      + RUN_AS_USER=sonar

==========================================================================
#4.9) Start SonarQube
==========================================================================
 Switch to sonar user
 $ sudo su sonar
 $ cd /opt/sonarqube/bin/linux-x86-64/
 $ ./sonar.sh start

 Configure Systemd service
 $ cd /opt/sonarqube/bin/linux-x86-64/
 $ ./sonar.sh stop

 Create a systemd service file for SonarQube to run as System Startup.
 $ sudo nano /etc/systemd/system/sonar.service
      + ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
      + ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

 $ sudo systemctl start sonar
 $ sudo systemctl enable sonar
 $ sudo systemctl status sonar

==========================================================================
#4.10) Access SonarQube
==========================================================================
 Access SonarQube
 http://server_IP:9000 OR http://localhost:9000
 Login to SonarQube  with default administrator username and password is admin.

==========================================================================
#4.11) Creation of Project in SonarQube and Running SonarQube in JENINS
==========================================================================
- Move to SonarQube URL ---> Create a new project -->Project Key & Display Name
- Name your Token and Generate it  --> Select JAVA  and BUILD as MAVEN
- Copy the Maven scanner code
- Navigate to JENKINS URL ---> Under Build Job---> Execute Shell Command and copy the MAVEN SCANNER CODE
- Run the BUILD JOB and view the http://<<SONARQUBE-URL>>:9000/dashboard?id=<<projectkey>>
