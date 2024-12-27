pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPOSITORY_NAME = 'saitechnicaltask'
        DOCKER_IMAGE = 'saitechnicaltask'
        AWS_ACCOUNT_ID = '<your-aws-account-id>'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/SAI127001/TechnicalTask'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${env.DOCKER_IMAGE}")
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh 'aws ecr get-login-password --region ${env.AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_DEFAULT_REGION}.amazonaws.com'
                    }
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    sh "docker tag ${env.DOCKER_IMAGE}:latest ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_DEFAULT_REGION}.amazonaws.com/${env.ECR_REPOSITORY_NAME}:latest"
                    sh "docker push ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_DEFAULT_REGION}.amazonaws.com/${env.ECR_REPOSITORY_NAME}:latest"
                }
            }
        }

        stage('Deploy to Lambda') {
            steps {
                script {
                    // Terraform apply to deploy Lambda function
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
    }
}