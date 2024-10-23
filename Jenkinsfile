pipeline {
    agent any

    stages {
            


        stage('Checkout') {
            steps {
                // Cloner le dépôt depuis Git
                git 'https://github.com/Mohamed-KBIBECH/DevSecOps.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Construction de l\'image Docker...'
                sh 'docker build -t devsecops.'
            }
        }

        stage('Deploy Docker Container') {
    steps {
        echo 'Déploiement du conteneur Docker...'
        
        // Arrêter le conteneur en cours d'exécution (s'il existe)
        script {
            def containerId = sh(script: "docker ps -q --filter 'ancestor=decvsecops'", returnStdout: true).trim()
            if (containerId) {
                sh "docker stop ${containerId}"
                sh "docker rm ${containerId}"
            }
        }

        // Lancer le nouveau conteneur en mode détaché sans nohup
        sh 'docker run -d -p 8083:8090 decvsecops'
    }
}
// Ajout d'une nouvelle étape pour le scan ZAP
       stage('ZAP Security Scan') {
    steps {
        script {
            // URL de l'application accessible via ngrok
            def appUrl = 'https://ed3a-105-73-96-62.ngrok-free.app'

            // Démarrer le spidering de ZAP pour ajouter l'URL au contexte
            bat "curl \"http://localhost:8081/JSON/spider/action/scan/?url=${appUrl}&recurse=true\""
            
            // Attendre la fin du spidering (ajuster le temps si nécessaire)
            sleep(60)

            // Lancer le scan actif de ZAP
            bat "curl \"http://localhost:8081/JSON/ascan/action/scan/?url=${appUrl}&recurse=true&inScopeOnly=false&scanPolicyName=Default%20Policy&method=NULL&postData=NULL\""
            
            // Attendre la fin du scan actif
            sleep(300)
        }
    }
    post {
        always {
            // Récupérer un rapport ZAP au format HTML ou autre
            bat 'curl "http://localhost:8081/OTHER/core/other/htmlreport/" > zap_report1.html'
        }
    }
}


    
       stage('SCA with Dependency-Check') {
    steps {
        echo 'Analyse de la composition des sources avec OWASP Dependency-Check...'
        bat '"C:\\Users\\HP NOTEBOOK\\Downloads\\dependency-check-10.0.2-release\\dependency-check\\bin\\dependency-check.bat" --project "demo" --scan . --format HTML --out dependency-check-report4.xml --nvdApiKey 181c8fc5-2ddc-4d15-99bf-764fff8d50dc --disableAssembly'
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
