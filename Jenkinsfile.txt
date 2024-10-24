pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Cloner le dépôt
                git 'https://github.com/Mohamed-KBIBECH/DevSecOps.git'
            }
        }
        stage('Build') {
            steps {
                // Construire le projet Maven
                sh 'mvn clean install'
            }
        }
        stage('Test') {
            steps {
                // Exécuter les tests
                sh 'mvn test'
            }
        }
        stage('Deploy') {
            steps {
                // Déploiement (peut être remplacé par votre stratégie de déploiement)
                sh 'echo "Déploiement de l\'application..."'
            }
        }
    }

    post {
        always {
            // Archive les fichiers importants à la fin
            archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
        }
        success {
            // Notifier en cas de succès
            echo 'Le build a réussi !'
        }
        failure {
            // Notifier en cas d'échec
            echo 'Le build a échoué.'
        }
    }
}
