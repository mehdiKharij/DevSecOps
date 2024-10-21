
  pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/Mohamed-KBIBECH/DevSecOps.git',
                    credentialsId: 'gitSec'
            }
        }
        stage('Build') {
            steps {
                bat './mvnw clean install'
            }
        }
    }
}
