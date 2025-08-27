pipeline {
  agent any
  options { timestamps() }

  environment {
    DOCKER_IMAGE = 'chand93/java-k8s-demo'
    DOCKER_TAG   = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        // The automatic "Declarative: Checkout SCM" already checked out the repo.
        // If you prefer, you can remove this stage entirely.
        checkout scm
      }
    }

    stage('Build & Test') {
      steps {
        dir('app') {
          sh 'chmod +x mvnw'
          sh './mvnw -B clean verify'
        }
      }
      post {
        // Our demo has no tests yet, so don't fail the build if no reports
        always { junit allowEmptyResults: true, testResults: 'app/target/surefire-reports/*.xml' }
      }
    }

    stage('Build Image') {
      steps {
        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}:latest ."
      }
    }

    stage('Push Image') {
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

