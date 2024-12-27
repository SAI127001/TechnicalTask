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

                // Check if the ECR repository exists
                def repoExists = sh(
                    script: "aws ecr describe-repositories --repository-names saitechnicaltask || echo 'NOT_FOUND'",
                    returnStdout: true
                ).trim()

                // If the repository exists, import it into Terraform
                if (repoExists.contains('repositoryUri')) {
                    echo "ECR repository already exists. Importing into Terraform state."
                    sh 'terraform import aws_ecr_repository.saitechnicaltask saitechnicaltask'
                } else {
                    echo "ECR repository does not exist. Proceeding with creation in Terraform."
                }

                // Proceed with Terraform plan and apply
                withCredentials([aws(credentialsId: '888958595564')]) {
                    sh 'terraform destroy -target=aws_lambda_function.saitechnicaltask'
                    sh 'terraform plan'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}

    }
}