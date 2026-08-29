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

                            rm -f /kaniko/.docker/config.json
                        '''
                    }
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                container('trivy') {
                    sh '''
                        trivy image \
                          --severity HIGH,CRITICAL \
                          --ignore-unfixed \
                          --exit-code 1 \
                          ${IMAGE_REPO}:${IMAGE_TAG}
                    '''
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
        stage('GitOps Update Image Tag') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-creds',
                        usernameVariable: 'GIT_USER',
                        passwordVariable: 'GIT_TOKEN'
                    )
            ]) {
                sh '''
                    sed -i "s/^  tag: .*/  tag: ${IMAGE_TAG}/" helm/devops-app/values.yaml

                    echo "Updated image configuration:"
                    grep -A3 "^image:" helm/devops-app/values.yaml

                    git config user.name "jenkins"
                    git config user.email "jenkins@local"

                    git add helm/devops-app/values.yaml

                    if git diff --cached --quiet; then
                        echo "No GitOps change required."
                        exit 0
                    fi

                    git commit -m "gitops: deploy image ${IMAGE_TAG}"

                    git remote set-url origin \
                        https://${GIT_USER}:${GIT_TOKEN}@github.com/Filllix/devops-kubernetes-project.git

                    git push origin HEAD:main
                '''
        }
    }
}