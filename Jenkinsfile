pipeline {
    agent { label 'agent-1' }

    parameters {
        choice(name: 'ENV', choices: ['dev', 'qa', 'prod'], description: 'Deployment environment')
    }

    environment {
        // Define ports mapping
        DEV_PORT = "8081"
        QA_PORT = "8082"
        PROD_PORT = "8083"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push') {
            steps {
                // Best Practice: Wrap in credentials block (uncomment if you have creds set up)
                // withCredentials([usernamePassword(credentialsId: 'docker-hub-auth', ...)]) {
                    sh '''
                    docker build -t labdocker12/jenkins-demo-app:${BUILD_NUMBER} .
                    docker push labdocker12/jenkins-demo-app:${BUILD_NUMBER} 
                    '''
                // }
            }
        }

        stage('Secrets Test') {
            steps {
                withCredentials([string(credentialsId: 'app-secret', variable: 'APP_SECRET')]) {
                    sh 'echo "Secret is $APP_SECRET"'
                }
            }
        }

        stage('Approval for Prod') {
          when {
            expression { params.ENV == 'prod' }
            }
          steps {
            input message: "Approve deployment to PROD?", ok: "Deploy"
            }
           }


        stage('Deploy') {
            steps {
                script {
                    // 1. Calculate the correct port based on user choice
                    env.DEPLOY_PORT = ""
                    if (params.ENV == "dev") env.DEPLOY_PORT = env.DEV_PORT
                    if (params.ENV == "qa") env.DEPLOY_PORT = env.QA_PORT
                    if (params.ENV == "prod") env.DEPLOY_PORT = env.PROD_PORT
                    
                    echo "Deploying to ${params.ENV} on port ${env.DEPLOY_PORT}"

                    // 2. Run the container with the correct name (demo-dev, demo-qa, etc.)
                    sh """
                    docker rm -f demo-${params.ENV} || true
                    docker run -d --name demo-${params.ENV} -p ${env.DEPLOY_PORT}:80 labdocker12/jenkins-demo-app:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    // Check the Dynamic Port (not hardcoded 8082!)
                    sh "sleep 5"
                    sh "curl http://localhost:${env.DEPLOY_PORT}"
                }
            }
        }

        stage('Update Nginx') {
            steps {
                script {
                    // This updates Nginx to point to the port we just deployed
                    // It replaces "proxy_pass http://localhost:xxxx;" with the new port
                    sh """
                    sudo sed -i -E 's/localhost:[0-9]+/localhost:${env.DEPLOY_PORT}/g' /etc/nginx/sites-enabled/default
                    sudo nginx -t
                    sudo systemctl reload nginx
                    """
                }
            }
        }

        stage('Verify Access') {
            steps {
                sh 'sleep 2'
                sh 'curl http://localhost' 
            }
        }
    }
}
