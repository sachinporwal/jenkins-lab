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
                sh "docker build -t jenkins-demo-app:${BUILD_NUMBER} ."
            }
        }

        stage('Start Green') {
            steps {
                sh '''
                docker rm -f demo-new || true
                docker run -d --name demo-new -p 8082:80 jenkins-demo-app:${BUILD_NUMBER}
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh 'sleep 5'
                sh 'curl http://localhost:8082'
            }
        }

        stage('Switch Traffic') {
            steps {
                sh '''
                sudo sed -i 's/8081/8082/g' /etc/nginx/sites-enabled/default
                sudo nginx -t
                sudo systemctl reload nginx
                '''
            }
        }

        stage('Stop Old Version') {
            steps {
                sh 'docker rm -f demo || true'
            }
        }

        stage('Promote Green') {
            steps {
                sh '''
                docker rename demo-new demo
                '''
            }
        }
    }
}
