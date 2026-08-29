pipeline {
    agent {
        label 'node-agent'
    }

    options {
        skipDefaultCheckout(true)
    }

    environment {
        IMAGE_REPO = 'aldocloud/devops-kubernetes-project'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Get Image Tag') {
            steps {
                script {
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse HEAD',
                        returnStdout: true
                    ).trim()

                    echo "Image tag: ${env.IMAGE_TAG}"
                }
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
                    sh '''
                        helm template devops-app helm/devops-app \
                        > /tmp/rendered.yaml
                    '''
                }
            }
        }

        stage('Build and Push Image') {
            steps {
                container('kaniko') {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-creds',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_TOKEN'
                        )
                    ]) {
                        sh '''
                            mkdir -p /kaniko/.docker

                            AUTH=$(printf "%s:%s" "$DOCKER_USER" "$DOCKER_TOKEN" | base64 | tr -d '\\n')

                            printf '{"auths":{"https://index.docker.io/v1/":{"auth":"%s"}}}' \
                              "$AUTH" > /kaniko/.docker/config.json

                            /kaniko/executor \
                              --context="${WORKSPACE}/app" \
                              --dockerfile="${WORKSPACE}/app/Dockerfile" \
                              --destination="${IMAGE_REPO}:${IMAGE_TAG}" \
                              --destination="${IMAGE_REPO}:latest"

                            rm -f /kaniko/.docker/config.json
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline SUCCESS - image ${IMAGE_REPO}:${IMAGE_TAG} pushed."
        }

        failure {
            echo 'Pipeline failed.'
        }
    }
}