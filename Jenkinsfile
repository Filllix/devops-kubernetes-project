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
    }

    post {
        success {
            echo 'Node.js pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed.'
        }
    }
}