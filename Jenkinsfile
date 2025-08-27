pipeline {
  agent any
  tools { jdk 'jdk17'; maven 'maven3' }
  options { ansiColor('xterm'); timestamps() }

  parameters {
    booleanParam(name: 'PUSH_IMAGE', defaultValue: true, description: 'Push image to Docker Hub')
    booleanParam(name: 'DEPLOY_TO_K8S', defaultValue: true, description: 'Deploy to Kubernetes')
    string(name: 'K8S_NAMESPACE', defaultValue: 'default', description: 'Kubernetes namespace')
  }

  environment {
    DOCKER_IMAGE = 'chand93/java-k8s-demo'
    DOCKER_TAG   = "${env.BUILD_NUMBER}" // simple, unique tag per build
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/Chandan1693/java-k8s-cicd-demo.git'
      }
    }

    stage('Build & Test') {
      steps {
        sh 'mvn -f app/pom.xml -B clean verify'
      }
      post {
        always { junit 'app/target/surefire-reports/*.xml' }
      }
    }

    stage('Build Image') {
      steps {
        sh """
          docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}:latest .
        """
      }
    }

    stage('Push Image') {
      when { expression { return params.PUSH_IMAGE } }
      steps {
        withDockerRegistry(credentialsId: 'docker-cred') {
          sh """
            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
            docker push ${DOCKER_IMAGE}:latest
          """
        }
      }
    }

    stage('Deploy to K8s') {
      when { expression { return params.DEPLOY_TO_K8S } }
      steps {
        withKubeConfig(credentialsId: 'k8s-kubeconfig') {
          sh """
            # Ensure manifests exist in cluster (idempotent)
            kubectl -n ${params.K8S_NAMESPACE} apply -f k8s/deployment.yaml
            kubectl -n ${params.K8S_NAMESPACE} apply -f k8s/service.yaml

            # Roll to the build tag we just pushed/built
            kubectl -n ${params.K8S_NAMESPACE} set image deploy/java-k8s-demo app=${DOCKER_IMAGE}:${DOCKER_TAG}

            # Optional: avoid pulling on every pod restart if you prefer (you already added imagePullSecrets)
            # kubectl -n ${params.K8S_NAMESPACE} patch deploy/java-k8s-demo \
            #   -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","imagePullPolicy":"IfNotPresent"}]}}}}'

            kubectl -n ${params.K8S_NAMESPACE} rollout status deploy/java-k8s-demo
          """
        }
      }
    }
  }

  post {
    success { echo "✅ Build ${env.BUILD_NUMBER} deployed: ${DOCKER_IMAGE}:${DOCKER_TAG}" }
    failure { echo "❌ Build failed" }
  }
}

