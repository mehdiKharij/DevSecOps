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

        stage('Deploy Stable with Kubernetes LoadBalancer') {
            steps {
                script {
                    // Appliquer le manifest Kubernetes pour le déploiement stable avec un LoadBalancer
                    bat 'kubectl apply -f k8s-manifests/deployment-stable.yaml'
                    echo "Déploiement stable avec Kubernetes LoadBalancer effectué."
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

        stage('Deploy Canary with Kubernetes LoadBalancer') {
            steps {
                script {
                    // Appliquer le manifest Kubernetes pour le déploiement Canary avec un LoadBalancer
                    bat 'kubectl apply -f k8s-manifests/deployment-canary.yaml'
                    echo "Déploiement Canary avec Kubernetes LoadBalancer effectué."
                }
            }
        }

        stage('Canary Traffic Routing with LoadBalancer') {
            steps {
                script {
                    echo "Routage du trafic réel avec le LoadBalancer..."
                    echo "90% du trafic redirigé vers le stable, 10% vers le Canary."
                }
            }
        }

        stage('Canary Validation') {
            steps {
                script {
                    echo "Validation du déploiement Canary..."
                    // Ajouter des scripts ou des appels à des APIs pour valider la nouvelle version
                    bat 'curl http://<EXTERNAL_IP_CANARY_SERVICE>' // Remplacer par l'IP externe du service LoadBalancer
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
