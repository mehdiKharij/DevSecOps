pipeline {
    agent any

    stages {
       stage('SCA with Dependency-Check') {
    steps {
        echo 'Analyse de la composition des sources avec OWASP Dependency-Check...'
        bat '"C:\\Users\\HP NOTEBOOK\\Downloads\\dependency-check-10.0.2-release\\dependency-check\\bin\\dependency-check.bat" --project "demo" --scan . --format HTML --out dependency-check-report2.xml --nvdApiKey 181c8fc5-2ddc-4d15-99bf-764fff8d50dc --disableAssembly'
    }
}
        stage('OWASP ZAP Security Scan') {
            steps {
                script {
                    zap(
                        zapHome: 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\ZAP\Zed Attack Proxy', // Le chemin vers l'installation de ZAP si nécessaire
                        targetURL: 'http://localhost:8090',
                        failBuild: false, // Si tu veux que la build échoue si ZAP détecte des vulnérabilités
                        reportsDir: 'zap-reports',
                        format: 'html',
                        reportName: 'OWASP-ZAP-Report'
                    )
                }
            }
        }
        
        stage('Post-Processing') {
            steps {
                // Par exemple : Publier les rapports OWASP ZAP
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'zap-reports',
                    reportFiles: 'OWASP-ZAP-Report.html',
                    reportName: 'OWASP ZAP Security Report'
                ])
            }
        }


        stage('Checkout') {
            steps {
                // Cloner le dépôt depuis Git
                git 'https://github.com/Mohamed-KBIBECH/DevSecOps.git'
            }
        }
        stage('Build') {
            steps {
                // Construire le projet avec Maven
                // Utiliser mvnw si Maven Wrapper est utilisé, sinon remplacer par 'mvn'
                bat 'mvnw clean install'
            }
        }
        stage('Test') {
            steps {
                // Exécuter les tests unitaires et d'intégration
                bat 'mvnw test'
            }
        }
        stage('Package') {
            steps {
                // Créer le package JAR ou WAR
                bat 'mvnw package'
            }
        }
        stage('Deploy') {
            steps {
                // Déploiement (peut être ajusté selon vos besoins)
                echo 'Déploiement de l\'application...'
            }
        }
        stage('Secret Scanning') {
    steps {
        echo 'Scanning des secrets avec GitLeaks...'
        bat 'gitleaks detect --source . --report-format json --report-path gitleaks-report.json'
    }
}
        stage('Analyze Secrets Report') {
    steps {
        script {
            def report = readFile('gitleaks-report.json')
            if (report.contains('leak')) {
                error 'Secrets détectés ! Le build est arrêté.'
            }
        }
    }
}
    



      


    }

    post {
        always {
            // Archiver les fichiers générés (JAR/WAR) dans le répertoire target
            archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
        }
        success {
            // Notification de succès
            echo 'Le build a réussi et les tests ont été validés !'
        }
        failure {
            // Notification d'échec
            echo 'Le build a échoué.'
        }
    }
}
