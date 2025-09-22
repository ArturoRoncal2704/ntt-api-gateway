# Etapa de build: compila la app con Maven
FROM maven:3.9.6-eclipse-temurin-11 AS build
WORKDIR /workspace
COPY pom.xml .
RUN mvn -q -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -q -DskipTests clean package

# Etapa de runtime: solo incluye el JAR y JDK necesario
FROM openjdk:11-jdk-slim
WORKDIR /app

# Copiar el jar desde la etapa de build
COPY --from=build /workspace/target/api_gateway-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8190

# Variables de entorno por defecto
ENV SPRING_PROFILES_ACTIVE=docker
ENV SPRING_CONFIG_IMPORT=optional:configserver:http://config-server:8888
ENV EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://ntt-eureka-server:8761/eureka

ENTRYPOINT ["java", "-jar", "app.jar"]
