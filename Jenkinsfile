pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/SAI127001/TechnicalTask.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t saitechnicaltask .'
            }
        }
        stage('Push to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your_account_id>.dkr.ecr.us-east-1.amazonaws.com
                docker tag s3-to-rds:latest <your_account_id>.dkr.ecr.us-east-1.amazonaws.com/s3-to-rds:latest
                docker push <your_account_id>.dkr.ecr.us-east-1.amazonaws.com/s3-to-rds:latest
                '''
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }
    }
}