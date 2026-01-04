pipeline {
    agent {label 'agent-1'}

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        parameters {
          choice(name: 'ENV', choices: ['dev', 'qa', 'prod'], description: 'Deployment environment')
        }

        environment {
          DEV_PORT = "8081"
          QA_PORT = "8082"
          PROD_PORT = "8083"
        }

        

        stage('Build Docker Image & PUSH to Docker Repo') {
            steps {
                sh '''	
                  docker build -t labdocker12/jenkins-demo-app:${BUILD_NUMBER} .
                  
                  docker push labdocker12/jenkins-demo-app:${BUILD_NUMBER} 
                  '''
            }
        }

        stage('Secrets Test') {
          steps {
            withCredentials([string(credentialsId: 'app-secret', variable: 'APP_SECRET')]) {
            sh 'echo "Secret is $APP_SECRET"'
            }
          }
        }

        

        stage('Deploy') {
          steps {
            script {
              def port = ""
                if (params.ENV == "dev") port = env.DEV_PORT
                if (params.ENV == "qa") port = env.QA_PORT
                if (params.ENV == "prod") port = env.PROD_PORT

            sh """
            docker rm -f demo-${params.ENV} || true
            docker run -d --name demo-${params.ENV} -p ${port}:80 labdocker12/jenkins-demo-app:${BUILD_NUMBER}
            """
             }
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

