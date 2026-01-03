pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Code checked out'
            }
        }

        stage('Build') {
            steps {
                echo 'Build step (nothing to compile for shell app)'
            }
        }

        stage('Run App') {
            steps {
                sh 'chmod +x app/app.sh'
                sh './app/app.sh'
            }
        }
    }
}

