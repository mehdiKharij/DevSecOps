pipeline {
    agent any

    stages {
        // Ajout d'une nouvelle étape pour le scan ZAP
        stage('ZAP Security Scan') {
            steps {
                script {
                    // Lancer ZAP en mode daemon
                    //bat 'zap.bat -daemon -host localhost -port 8081 -config api.disablekey=true'
                    // URL de l'application à scanner
                    def appUrl = 'http://localhost:8090'  // Remplace par l'URL réelle de ton application
                    // Démarrer le scan actif de ZAP
                    bat "curl http://localhost:8081/JSON/ascan/action/scan/?url=${appUrl}&recurse=true&inScopeOnly=false&scanPolicyName=Default+Policy&method=NULL&postData=NULL"
                    // Attendre que le scan se termine (tu peux ajuster le temps selon les besoins)
                    sleep(300)
                }
            }
            post {
                always {
                    // Optionnel : Récupérer un rapport ZAP au format HTML ou autre
                    bat 'curl http://localhost:8081/OTHER/core/other/htmlreport/ > zap_report.html'
                    
                }
            }
        }
    
       stage('SCA with Dependency-Check') {
    steps {
        echo 'Analyse de la composition des sources avec OWASP Dependency-Check...'
        bat '"C:\\Users\\HP NOTEBOOK\\Downloads\\dependency-check-10.0.2-release\\dependency-check\\bin\\dependency-check.bat" --project "demo" --scan . --format HTML --out dependency-check-report3.xml --nvdApiKey 181c8fc5-2ddc-4d15-99bf-764fff8d50dc --disableAssembly'
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
