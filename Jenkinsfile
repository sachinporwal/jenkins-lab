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
                  docker rm -f demo-new || true
                  docker run -d --name demo -p 8081:80 jenkins-demo-app:${BUILD_NUMBER}
                '''
            }
        }

        stage('Verify') {
            steps {
                sh 'curl http://localhost:8081'
            }
        }
    }
}
