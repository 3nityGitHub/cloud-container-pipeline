# ---- Stage 1: build ----
FROM gradle:8-jdk17 AS build
WORKDIR /app
COPY . .
RUN gradle build --no-daemon

# ---- Stage 2: run ----
FROM eclipse-temurin:17-jre
WORKDIR /app
RUN useradd -r appuser
COPY --from=build /app/build/libs/*-SNAPSHOT.jar app.jar
USER appuser
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
