pipeline {
    
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t jenkins-demo-app:${BUILD_NUMBER} .'
            }
        }

        stage('Run Container') {
            steps {
                sh '''
                  docker rm -f demo || true
                  docker run -d --name demo -p 8082:80 jenkins-demo-app:${BUILD_NUMBER}
                '''
            }
        }

        stage('Verify') {
            steps {
                sh 'curl http://localhost:8082'
            }
        }
    }
}
