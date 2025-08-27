pipeline {
  agent any
  options { timestamps() }
  environment {
    DOCKER_IMAGE = 'chand93/java-k8s-demo'
    DOCKER_TAG   = "${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') {
      steps { git branch: 'main', url: 'https://github.com/Chandan1693/java-k8s-cicd-demo.git' }
    }
    stage('Build & Test') {
      steps { sh './app/mvnw -B -f app/pom.xml clean verify' }
      post { always { junit 'app/target/surefire-reports/*.xml' } }
    }
    stage('Build Image') {
      steps { sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}:latest ." }
    }
    stage('Push Image') {
      when { expression { return true } }
      steps {
        withDockerRegistry(credentialsId: 'docker-cred') {
          sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
          sh "docker push ${DOCKER_IMAGE}:latest"
        }
      }
    }
    stage('Deploy to K8s') {
      steps {
        withKubeConfig(credentialsId: 'k8s-kubeconfig') {
          sh """
            kubectl apply -f k8s/deployment.yaml
            kubectl apply -f k8s/service.yaml
            kubectl set image deploy/java-k8s-demo app=${DOCKER_IMAGE}:${DOCKER_TAG}
            kubectl rollout status deploy/java-k8s-demo
          """
        }
      }
    }
  }
}

