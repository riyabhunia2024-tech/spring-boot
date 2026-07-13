# ---------- Stage 1: Build the Spring Boot app ----------
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# ---------- Stage 2: Final image with Java + Nginx + Supervisor ----------
FROM eclipse-temurin:17-jre-alpine

RUN apk add --no-cache nginx supervisor

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Nginx config - proxies port 80 -> Spring Boot on 8080
COPY nginx.conf /etc/nginx/nginx.conf

# Supervisor config - runs both nginx and java together
COPY supervisord.conf /etc/supervisord.conf

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisord.conf"]

