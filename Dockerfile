# Build stage
FROM maven:3.9.8-eclipse-temurin-17 AS build
WORKDIR /build
COPY app/pom.xml app/pom.xml
RUN mvn -q -f app/pom.xml -DskipTests dependency:go-offline
COPY app app
RUN mvn -q -f app/pom.xml -DskipTests package

# Runtime stage
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /build/app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
