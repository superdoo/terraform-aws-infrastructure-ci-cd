pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('my-aws-credentials-id')
        AWS_SECRET_ACCESS_KEY = credentials('my-aws-credentials-id')
        TF_VAR_region = 'us-west-2'
    }

    stages {
        stage('Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Validate') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }
        stage('Apply') {
            when {
                branch 'main'
            }
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
