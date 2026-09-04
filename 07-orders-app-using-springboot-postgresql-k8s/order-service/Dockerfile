FROM eclipse-temurin:17-jre-alpine

RUN addgroup -S spring && adduser -S spring -G spring

WORKDIR /app

COPY target/order-service-1.0.0.jar app.jar

USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]