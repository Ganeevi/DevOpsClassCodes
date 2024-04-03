pipeline{
    agent { label 'dev' }
    tools {
        maven 'myMVN'
        jdk 'myJDK'
    }
    environment {
        AWS_ACCOUNT_ID = '533267022876'
        AWS_DEFAULT_REGION = 'ap-south-1'
        DOCKER_IMAGE_NAME = '$JOB_NAME'
		DOCKER_IMAGE_TAG = '$BUILD_NUMBER'
        ECR_REPOSITORY_NAME = '${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com'
		}
		
    stages {
        stage ('Compile') {
            steps {
                git branch: 'master',
                url: 'https://github.com/Ganeevi/DevOpsClassCodes.git'
            }
        }
		stage('Build') {
            steps {
                sh 'mvn clean install'
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
                sh 'ls -l /tmp/workspace/${JOB_NAME}/target/addressbook.war'
            }
            post {
                success {
                    sh 'sudo yum install -y docker; sudo systemctl start docker; sudo systemctl enable docker'
                }
            }
        }
        stage('Build and Deploy to "DEV" environment') {
            steps {
				sh 'sudo chmod 666 /var/run/docker.sock'
				sh 'cd /tmp/workspace/${JOB_NAME}; pwd; sudo cp -pr target/addressbook.war .; ls -l /tmp/workspace/${JOB_NAME}/addressbook.war'
				sh "docker build -t ${ECR_REPOSITORY_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
				sh "sudo docker run -itd -P ${ECR_REPOSITORY_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
				
            }
            post {
                success {
                    sh 'echo "********** Stage Successful **********"'
                }
                failure {
                    sh 'echo "********** Stage Failed, Validate **********"'
                }
            }
        }
		stage('Creating ECR Repository') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
					// sh " *********************************** Need to work on Repository creation ***********************************"
					//sh "echo 'Creating new if now already exist'"
					//sh "aws ecr create-repository --repository-name ${JOB_NAME} --region ${AWS_DEFAULT_REGION}"
                }
            }
        }
        stage('Pushing to ECR from Dev') {
            steps {
                script {
                    sh "docker push ${ECR_REPOSITORY_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
				}
            }
        }
		stage('Deploy to "STAGE" environment') {
			agent { label 'stage' }
            steps {
                script {
					sh 'sudo chmod 666 /var/run/docker.sock'
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker pull ${ECR_REPOSITORY_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
					sh "docker run -itd -P ${ECR_REPOSITORY_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
	}
    post {
		success {
            sh 'echo "Congratulations! Deployment Successful"'
            sh 'sudo docker images; sudo docker ps -a'
        }
        always {
            // Cleanup tasks, finalization steps, etc., <<< if required >>>
            //sh 'docker stop $(docker ps -a -q)|| true'
            //sh 'docker rm $(docker ps -a -q) || true'
			//sh 'docker rmi -f $(docker images -a -q)|| true 
        }
		
        failure {
            sh 'echo "Failure in execution, validate"'
		}
	}
}
