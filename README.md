# Java App CI/CD on Kubernetes (Jenkins + SonarQube + Trivy)

End-to-end pipeline that builds, tests, scans, containers, and deploys a Java (Spring Boot) API to Kubernetes using Jenkins. Docker image is pushed to Docker Hub.

## Quick start
- Build locally: `cd app && ./mvnw clean verify`
- Run locally: `./mvnw spring-boot:run` then open http://localhost:8080/health
- Docker build: `docker build -t chand93/java-k8s-demo:latest .`
- K8s apply: `kubectl apply -f k8s/`

See Jenkinsfile for CI/CD stages. SonarQube + Trivy added later in the week.
