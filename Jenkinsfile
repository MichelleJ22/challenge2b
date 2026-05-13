pipeline {
    agent any

    environment {
        AWS_REGION   = 'us-east-2'
        AWS_ACCOUNT  = '113892881104'
        ECR_REPO     = "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/hello-flask"
        CLUSTER_NAME = 'enterprise-cluster'
        IMAGE_TAG    = "${BUILD_NUMBER}"
        KUBECONFIG   = "${WORKSPACE}/kubeconfig"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Verify Tools') {
            steps {
                sh '''
                    docker --version
                    aws --version
                    kubectl version --client
                    helm version
                    git --version
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh '''
                        docker build -t hello-flask:${IMAGE_TAG} .
                    '''
                }
            }
        }

        stage('Login, Push, and Deploy') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} \
                          | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com

                        docker tag hello-flask:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                        docker tag hello-flask:${IMAGE_TAG} ${ECR_REPO}:latest

                        docker push ${ECR_REPO}:${IMAGE_TAG}
                        docker push ${ECR_REPO}:latest

                        aws eks update-kubeconfig \
                          --name ${CLUSTER_NAME} \
                          --region ${AWS_REGION} \
                          --kubeconfig ${KUBECONFIG}

                        helm upgrade --install webapp ./helm \
                          --namespace default \
                          --set image.repository=${ECR_REPO} \
                          --set image.tag=${IMAGE_TAG} \
                          --kubeconfig ${KUBECONFIG}

                        kubectl --kubeconfig ${KUBECONFIG} rollout status deployment/webapp -n default
                        kubectl --kubeconfig ${KUBECONFIG} get pods -n default
                        kubectl --kubeconfig ${KUBECONFIG} get svc -n default
                        kubectl --kubeconfig ${KUBECONFIG} get ingress -n default
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}