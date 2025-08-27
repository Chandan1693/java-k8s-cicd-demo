pipeline {
  agent any

  options {
    timestamps()
    skipDefaultCheckout(false)
  }

  environment {
    // Change to your own repo/image if you use Docker later
    DOCKER_IMAGE = 'your-docker-user/java-k8s-cicd-demo'
    DOCKER_TAG   = "build-${env.BUILD_NUMBER}"
  }

  stages {
    stage('Preflight') {
      steps {
        sh 'java -version'
        dir('app') {
          sh 'chmod +x mvnw'
          sh './mvnw -v'
        }
      }
    }

    stage('Build & Test') {
      steps {
        dir('app') {
          sh './mvnw -B clean verify'
        }
      }
      post {
        always {
          junit 'app/target/surefire-reports/*.xml'
          archiveArtifacts artifacts: 'app/target/*.jar', fingerprint: true, allowEmptyArchive: true
        }
      }
    }

    stage('Build Image') {
      when { expression { fileExists('app/Dockerfile') || fileExists('Dockerfile') } }
      steps {
        script {
          def dfPath = fileExists('app/Dockerfile') ? 'app' : '.'
          sh "docker build -f ${dfPath}/Dockerfile -t ${DOCKER_IMAGE}:${DOCKER_TAG} ${dfPath}"
        }
      }
    }

    stage('Push Image') {
      when { expression { return env.DOCKER_PUSH == 'true' } }
      steps {
        sh 'docker push ${DOCKER_IMAGE}:${DOCKER_TAG}'
      }
    }

    stage('Deploy to K8s') {
      when { expression { fileExists('k8s') } }
      steps {
        sh 'kubectl apply -f k8s/'
      }
    }
  }
}

