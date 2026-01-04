pipeline {
    agent {label 'agent-1'}

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image & PUSH to ECR') {
            steps {
                sh '''	
                  docker build -t labdocker12/jenkins-demo-app:${BUILD_NUMBER} .
                  
                  docker push labdocker12/jenkins-demo-app:${BUILD_NUMBER} 
                  '''
            }
        }

        stage('Start Green') {
            steps {
                sh '''
                docker rm -f demo-new || true
                docker rm -f demo || true
                docker run -d --name demo-new -p 8082:80 labdocker12/jenkins-demo-app:${BUILD_NUMBER}
                '''
               } 
        }

        stage('Health Check') {
            steps {
                sh 'sleep 5'
                sh 'curl http://localhost:8082'
            }
        }

        stage('Switch Traffic to Green') {
            steps {
                sh '''
                sudo sed -i 's/8081/8082/g' /etc/nginx/sites-enabled/default
                sudo nginx -t
                sudo systemctl reload nginx
                '''
            }
        }

        stage('Post Switch Verification') {
            steps {
                sh 'sleep 5'
                sh 'curl http://localhost'
            }
        }

        stage('Promote Green') {
            steps {
                sh '''
                docker rm -f demo || true
                docker rename demo-new demo
                '''
            }
        }

    }

    post {
        failure {
            sh '''
            echo "Deployment failed, rolling back"
            sudo sed -i 's/8082/8081/g' /etc/nginx/sites-enabled/default
            sudo nginx -t
            sudo systemctl reload nginx
            docker rm -f demo-new || true
            '''
        }
    }
}

