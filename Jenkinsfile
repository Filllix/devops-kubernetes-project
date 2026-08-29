pipeline {
    agent {
        label 'node-agent'
    }

    options {
        skipDefaultCheckout(true)
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                container('node') {
                    dir('app') {
                        sh 'npm ci'
                    }
                }
            }
        }

        stage('Validate Node.js') {
            steps {
                container('node') {
                    sh 'node --check app/server.js'
                }
            }
        }

        stage('Helm Lint') {
            steps {
                container('helm') {
                    sh 'helm lint helm/devops-app'
                }
            }
        }

        stage('Helm Template') {
            steps {
                container('helm') {
                    sh 'helm template devops-app helm/devops-app > /tmp/rendered.yaml'
                }
            }
        }
    }

    post {
        success {
            echo 'Node.js and Helm validation completed successfully.'
        }

        failure {
            echo 'Pipeline failed.'
        }
    }
}