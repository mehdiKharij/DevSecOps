pipeline {
    agent any

    stages {
        // 1. Cloner le dépôt
        stage('Checkout') {
            steps {
                git 'https://github.com/mehdiKharij/DevSecOps.git'
            }
        }
        
        // 2. Analyse de la composition des sources avec Dependency-Check
        stage('SCA with Dependency-Check') {
            steps {
                echo 'Analyse de la composition des sources avec OWASP Dependency-Check...'
                bat '"C:\Users\user\Downloads\dependency-check\bin\dependency-check.bat" --project "demo" --scan . --format HTML --out dependency-check-report.html --nvdApiKey 181c8fc5-2ddc-4d15-99bf-764fff8d50dc --disableAssembly'
            }
        }

        // 3. Analyse de sécurité des secrets avec GitLeaks
        stage('Secret Scanning') {
            steps {
                bat 'gitleaks detect --source . --report-format json --report-path gitleaks-report.json'
            }
        }

        // 4. Analyse du rapport de sécurité des secrets
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

        // 5. Exécution des tests
        stage('Test') {
            steps {
                bat 'mvnw.cmd test'
            }
        }

        // 6. Création du package
        stage('Package') {
            steps {
                bat 'mvnw.cmd package'
            }
        }

        // 7. Construction de l'image Docker stable
        stage('Build Docker Image') {
            steps {
                echo 'Construction de l\'image Docker...'
                bat 'docker build -t devsecops:stable .'
            }
        }

        // 8. Déploiement du conteneur stable
        stage('Deploy Stable Container') {
            steps {
                script {
                    // Vérifier si le conteneur stable est déjà en cours d'exécution
                    def stableContainer = bat(script: 'docker ps -q --filter "name=stable-container"', returnStdout: true).trim()

                    // Démarrer le conteneur stable sur le port 8082 si nécessaire
                    if (!stableContainer) {
                        bat "docker run -d -p 8082:8090 --name stable-container devsecops:stable"
                        echo "Conteneur stable démarré sur le port 8082."
                    } else {
                        echo "Le conteneur stable est déjà en cours d'exécution."
                    }
                }
            }
        }

        // 9. Construction de l'image Docker Canary
        stage('Build Canary Image') {
            steps {
                script {
                    def canaryImage = "devsecops:canary-${env.BUILD_NUMBER}"

                    // Construire l'image Docker Canary
                    bat "docker build -t ${canaryImage} ."
                    echo "Image Canary construite : ${canaryImage}"
                }
            }
        }

        // 10. Déploiement du conteneur Canary
        stage('Deploy Canary Container') {
            steps {
                script {
                    def canaryImage = "devsecops:canary-${env.BUILD_NUMBER}"

                    // Démarrer le conteneur Canary sur le port 8083
                    bat "docker run -d -p 8083:8090 --name canary-container2 ${canaryImage}"
                    echo "Conteneur Canary démarré sur le port 8083."
                }
            }
        }

        // 11. Simuler le routage du trafic Canary
        stage('Canary Traffic Routing (Simulated)') {
            steps {
                script {
                    echo "Simuler le routage du trafic vers le conteneur Canary..."
                    echo "10% du trafic redirigé vers le Canary (port 8083), 90% vers le stable (port 8082) (simulé)"
                }
            }
        }

        // 12. Validation du déploiement Canary
        stage('Canary Validation') {
            steps {
                script {
                    echo "Validation du déploiement Canary..."
                }
            }
        }

        // 13. Scan de sécurité avec ZAP
        stage('ZAP Security Scan') {
            steps {
                script {
                    def appUrl = 'https://ed3a-105-73-96-62.ngrok-free.app'
                    bat "curl \"http://localhost:8095/JSON/spider/action/scan/?url=${appUrl}&recurse=true\""
                    sleep(60)
                    bat "curl \"http://localhost:8095/JSON/ascan/action/scan/?url=${appUrl}&recurse=true&inScopeOnly=false&scanPolicyName=Default%20Policy&method=NULL&postData=NULL\""
                    sleep(300)
                }
            }
            post {
                always {
                    bat 'curl "http://localhost:8095/OTHER/core/other/htmlreport/" > zap_report1.html'
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
