pipeline {
  agent any
  environment {
    SCANNER_HOME = tool 'sonar-scanner'  // set up on Day 6
  }
  tools {
    jdk 'jdk17'      // configure in Jenkins → Global Tool Configuration (Day 5)
    maven 'maven3'   // configure in Jenkins (Day 5)
  }
  options {
    ansiColor('xterm')
    timestamps()
  }
  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/Chandan1693/java-k8s-cicd-demo.git'
      }
    }
    stage('Build & Test') {
      steps {
        sh 'mvn -f app/pom.xml -Dmaven.test.failure.ignore=false clean verify'
      }
    }
    stage('FS Scan (Trivy)') {
      when { expression { return false } } // enable on Day 6
      steps { sh 'trivy fs --exit-code 0 --format table -o trivy-fs-report.html .' }
    }
    stage('SonarQube') {
      when { expression { return false } } // enable on Day 6
      steps {
        withSonarQubeEnv('sonarqube') {
          sh '''${SCANNER_HOME}/bin/sonar-scanner \
            -Dsonar.projectKey=java-k8s-demo \
            -Dsonar.projectName=java-k8s-demo \
            -Dsonar.sources=app/src \
            -Dsonar.java.binaries=app/target'''
        }
      }
    }
    stage('Quality Gate') {
      when { expression { return false } } // enable on Day 6
      steps { waitForQualityGate abortPipeline: true, credentialsId: 'sonar-token' }
    }
    stage('Build Image') {
      steps { sh 'docker build -t chand93/java-k8s-demo:${BUILD_NUMBER} .' }
    }
    stage('Image Scan (Trivy)') {
      when { expression { return false } } // enable on Day 6
      steps { sh 'trivy image --exit-code 0 --format table -o trivy-image-report.html chand93/java-k8s-demo:${BUILD_NUMBER}' }
    }
    stage('Push Image') {
      steps {
        withDockerRegistry(credentialsId: 'docker-cred') {
          sh 'docker push chand93/java-k8s-demo:${BUILD_NUMBER}'
          sh 'docker tag chand93/java-k8s-demo:${BUILD_NUMBER} chand93/java-k8s-demo:latest'
          sh 'docker push chand93/java-k8s-demo:latest'
        }
      }
    }
    stage('Deploy to K8s') {
      steps {
        withKubeConfig(credentialsId: 'k8s-kubeconfig') {
          sh 'kubectl apply -f k8s/deployment.yaml'
          sh 'kubectl apply -f k8s/service.yaml'
          sh 'kubectl rollout status deploy/java-k8s-demo'
        }
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: 'trivy-*.html', fingerprint: true, onlyIfSuccessful: false
      junit 'app/target/surefire-reports/*.xml'
    }
  }
}
