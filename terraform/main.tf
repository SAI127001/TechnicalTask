pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPO = 'saitechnicaltask'
        IMAGE_TAG = 'latest'
        DOCKER_REGISTRY_CREDENTIAL = 'your-docker-registry-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-repo/s3-to-rds-glue.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${ECR_REPO}:${IMAGE_TAG}")
                }
            }
        }
        stage('Push Docker Image to ECR') {
            steps {
                script {
                    docker.withRegistry('https://<aws-account-id>.dkr.ecr.us-east-1.amazonaws.com', DOCKER_REGISTRY_CREDENTIAL) {
                        docker.image("${ECR_REPO}:${IMAGE_TAG}").push()
                    }
                }
            }
        }
        stage('Deploy to AWS') {
            steps {
                withAWS(credentials: 'your-aws-credentials') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage('Test Lambda Function') {
            steps {
                script {
                    sh 'aws lambda invoke --function-name s3-to-rds-glue-function output.txt'
                    sh 'cat output.txt'
                }
            }
        }
    }
}