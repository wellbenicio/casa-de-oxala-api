# ---- Build stage ----
FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /workspace

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Download dependencies first (layer cache)
RUN ./mvnw dependency:go-offline --batch-mode --no-transfer-progress

COPY src src

RUN ./mvnw package -DskipTests --batch-mode --no-transfer-progress

# ---- Runtime stage ----
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY --from=build /workspace/target/*.jar app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
