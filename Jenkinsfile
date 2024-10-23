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
                bat 'docker build -t devsecops:stable .'
            }
        }

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

        stage('Build Canary Image') {
            steps {
                script {
                    // Nom de l'image Canary avec un tag unique
                    def canaryImage = "devsecops:canary-${env.BUILD_NUMBER}"

                    // Construire l'image Docker Canary
                    bat "docker build -t ${canaryImage} ."
                    echo "Image Canary construite : ${canaryImage}"
                }
            }
        }

        stage('Deploy Canary Container') {
            steps {
                script {
                    // Nom de l'image Canary
                    def canaryImage = "devsecops:canary-${env.BUILD_NUMBER}"

                    // Démarrer le conteneur Canary sur le port 8083
                    bat "docker run -d -p 8083:8090 --name canary-container ${canaryImage}"
                    echo "Conteneur Canary démarré sur le port 8083."
                }
            }
        }

        stage('Canary Traffic Routing (Simulated)') {
            steps {
                script {
                    echo "Simuler le routage du trafic vers le conteneur Canary..."
                    // Ici, un proxy réel comme NGINX ou Traefik doit être configuré
                    echo "10% du trafic redirigé vers le Canary (port 8083), 90% vers le stable (port 8082) (simulé)"
                }
            }
        }

        stage('Canary Validation') {
            steps {
                script {
                    echo "Validation du déploiement Canary..."
                    // Vous pouvez ajouter des scripts ou des appels à des APIs pour valider la nouvelle version
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
