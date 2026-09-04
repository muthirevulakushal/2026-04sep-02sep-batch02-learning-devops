# FROM ibmjava:jre

FROM ubuntu:20.04

WORKDIR myapp

# RUN apt-get update -y && apt install default-jre -y

RUN apt-get update -y && apt install openjdk-17-jdk -y

COPY target/spring-boot-complete-0.0.1-SNAPSHOT.jar myapp.jar

EXPOSE 8080

CMD [ "java","-jar","myapp.jar" ]