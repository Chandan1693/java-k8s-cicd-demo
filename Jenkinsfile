pipeline {
  agent any
  options { timestamps() }
  environment {
    IMAGE = 'chandan1693/java-k8s-demo'
    TAG   = "${env.BUILD_NUMBER}"
  }
  stages {
    stage('Preflight') {
      steps {
        sh '''
          java -version || true
          ./app/mvnw -v
          docker version
          kubectl version --client=true
        '''
      }
    }
    stage('Build & Test') {
      steps {
        dir('app') {
          sh 'chmod +x mvnw'
          sh './mvnw -B clean verify'
        }
        junit 'app/target/surefire-reports/*.xml'
      }
    }
    stage('Build Image') {
      steps {
        sh 'docker build -t ${IMAGE}:${TAG} .'
      }
    }
    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-cred',
                     usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PWD')]) {
          sh '''
            echo "$DOCKER_PWD" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ${IMAGE}:${TAG}
            docker tag  ${IMAGE}:${TAG} ${IMAGE}:latest
            docker push ${IMAGE}:latest
          '''
        }
      }
    }
    stage('Deploy to K8s') {
      steps {
        withKubeConfig(credentialsId: 'k8s-kubeconfig') {
          sh '''
            # Try rolling update first; if resources don't exist, apply manifests
            kubectl set image deploy/java-k8s-demo app=${IMAGE}:${TAG} --record || true
            kubectl apply -f k8s/deployment.yaml
            kubectl apply -f k8s/service.yaml
            kubectl rollout status deploy/java-k8s-demo
          '''
        }
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: 'app/target/*.jar', fingerprint: true
      archiveArtifacts artifacts: 'trivy-*.html', fingerprint: true, allowEmptyArchive: true
    }
  }
}

