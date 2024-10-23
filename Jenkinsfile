pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Mohamed-KBIBECH/DevSecOps.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Construction de l\'image Docker...'
                bat 'docker build -t devsecops .'
            }
        }

        stage('Deploy Docker Container') {
    steps {
        echo 'Déploiement du conteneur Docker...'

        script {
            // Récupérer l'ID du conteneur en filtrant la sortie correctement
            def containerId = bat(script: 'for /f "tokens=*" %i in (\'docker ps -q --filter "ancestor=devsecops"\') do @echo %i', returnStdout: true).trim()

            if (containerId) {
                echo "Arrêt du conteneur existant : ${containerId}"
                bat "docker stop ${containerId}"
                bat "docker rm ${containerId}"
            }
        }

        // Démarrer le nouveau conteneur en mode détaché
        bat 'docker run -d -p 8082:8090 devsecops'

        // Vérifiez si le conteneur est bien démarré
        script {
            def runningContainer = bat(script: 'for /f "tokens=*" %i in (\'docker ps -q --filter "ancestor=devsecops"\') do @echo %i', returnStdout: true).trim()
            if (!runningContainer) {
                error 'Le conteneur Docker ne s\'est pas démarré correctement.'
            } else {
                echo "Conteneur démarré avec succès : ${runningContainer}"
            }
        }
    }
}

        stage('ZAP Security Scan') {
            steps {
                script {
                    def appUrl = 'https://ed3a-105-73-96-62.ngrok-free.app'
                    bat "curl \"http://localhost:8081/JSON/spider/action/scan/?url=${appUrl}&recurse=true\""
                    sleep(60)
                    bat "curl \"http://localhost:8081/JSON/ascan/action/scan/?url=${appUrl}&recurse=true&inScopeOnly=false&scanPolicyName=Default%20Policy&method=NULL&postData=NULL\""
                    sleep(300)
                }
            }
            post {
                always {
                    bat 'curl "http://localhost:8081/OTHER/core/other/htmlreport/" > zap_report1.html'
                }
            }
        }

        stage('SCA with Dependency-Check') {
            steps {
                echo 'Analyse de la composition des sources avec OWASP Dependency-Check...'
                bat '"C:\\Users\\HP NOTEBOOK\\Downloads\\dependency-check-10.0.2-release\\dependency-check\\bin\\dependency-check.bat" --project "demo" --scan . --format HTML --out dependency-check-report.html --nvdApiKey 181c8fc5-2ddc-4d15-99bf-764fff8d50dc --disableAssembly'
            }
        }

        stage('Test') {
            steps {
                bat 'mvnw.cmd test'
            }
        }

        stage('Package') {
            steps {
                bat 'mvnw.cmd package'
            }
        }

        stage('Secret Scanning') {
            steps {
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
            archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
        }
        success {
            echo 'Le build a réussi et les tests ont été validés !'
        }
        failure {
            echo 'Le build a échoué.'
        }
    }
}
