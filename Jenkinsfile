pipeline {
    agent any

    stages {
        stage('Clone') {
            steps {
                echo 'Code cloned from GitHub'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t jenkins-demo .'
            }
        }

        stage('Run Container') {
            steps {
                sh 'docker run --rm jenkins-demo'
            }
        }
    }
}

