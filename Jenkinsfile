pipeline{
    agent { label 'mySlave' }
    tools {
        maven 'myMVN'
        jdk 'myJDK'
    }
    environment {
	AWS_ACCOUNT_ID = '533267022876'
        AWS_DEFAULT_REGION = 'ap-south-1'
        IMAGE_REPO_NAME = "ramandeep"
        DOCKER_IMAGE_TAG = 'latest'
        ECR_REPOSITORY_NAME = '${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}'
    }
    stages {
      stage ('Compile') {
            steps {
                git branch: 'master',
                url: 'https://github.com/Ganeevi/DevOpsClassCodes.git'
            }
        }
        stage('Code-Review') {
            steps {
                sh 'mvn pmd:pmd'
            }
        }
        stage('Unit-Test') {
            steps {
                sh 'mvn test'
            }
            post {
                success {
                    junit testResults: 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Package') {
            steps {
                sh 'mvn package'
            }
            post {
                success {
                    sh 'sudo yum install -y docker; sudo systemctl start docker; sudo systemctl enable docker'
                }
            }
        }
        stage('Deploy') {
            steps {
                sh 'sudo sh deploy.sh'
            }
            post {
                success {
                    sh 'cd /docker-file'
                    sh 'sudo docker build -t docker:$BUILD_NUMBER .'
                    sh 'sudo docker run -itd -P docker:$BUILD_NUMBER'
                }
                failure {
                    sh 'echo "Failure in jenkins pipeline"'
                }
            }
        }
	stage('Login to ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"                }
            }
        }
	stage('Pushing to ECR') {
            steps{  
                script {
                    sh "docker tag docker:$BUILD_NUMBER ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:$BUILD_NUMBER"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:$BUILD_NUMBER"
                }
            }
      	}
    }
    post {
        success {
            sh 'echo "Congratulations! Deployment Successful"'
            sh 'sudo docker images; sudo docker ps -a'
        }
        failure {
            sh 'echo "Failure in execution, validate"'
        }
    }
}
