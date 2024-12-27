pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPOSITORY_NAME = 'saitechnicaltask'
        DOCKER_IMAGE = 'saitechnicaltask'
        AWS_ACCOUNT_ID = '888958595564'
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
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: '888958595564']]) {
              // your AWS CLI commands
               sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com'
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
                        withCredentials([aws(credentialsId: 'your-credentials-id')]) {
                          sh 'terraform plan'
                          sh 'terraform apply -auto-approve'

                        }
                    }
                }
            }
        }
    }
}