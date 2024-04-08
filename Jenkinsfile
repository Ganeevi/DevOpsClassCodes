// Issues to be fixed: install JFROG on Amazon Linux 2 rather than ubuntu, as different java - jdk versions gives issues.

pipeline {
    agent { 
		label 'artifactory' 
		}
    tools {
        jdk 'myJDK'
        maven 'myMVN'
    }
    environment {
        ACCOUNT_ID = "533267022876"
		DEFAULT_REGION = "ap-south-1"
		IMAGE_NAME = "${JOB_NAME}"
		IMAGE_TAG = "${BUILD_NUMBER}"
    }
    stages {
		stage('Prepare'){
            steps {
                sh 'sudo yum install -y git'
            }
        }
        stage('Checkout'){
            steps {
                git 'https://github.com/Ganeevi/DevOpsClassCodes.git'
            }
        }
		stage('Build'){
            steps {
                sh 'mvn clean install'
            }
        }
        stage('Code-Review'){
            steps {
                sh 'mvn pmd:pmd'
            }
        }
        stage('Unit-Test'){
            steps{
                sh 'mvn test'
            }
            post {
                success {
                    junit testResults: 'target/surefire-reports/*.xml'
                }
                failure {
                    sh 'echo "Unit-test failed"'
                }
            }
        }
        stage('package'){
            steps {
                sh 'mvn package'
            }
            post {
                success {
                    sh 'echo "Docker Package installation"'
				    sh 'sudo yum install -y docker'
				    sh 'sudo systemctl enable docker'
				    sh 'sudo systemctl start docker'
                }
            }
        }
/* =============================================== Jfrog Artifact ===============================================
		stage('Upload Jfrog Artifact') {
            steps {
				sh 'cd /tmp/workspace/${JOB_NAME}/target/' {
					rtServer (
						id: 'myServer',
						url: 'http://43.205.119.55:8081/artifactory/',
						credentialsId: 'jfrog-login',
						bypassProxy: true,
					)
					rtUpload (
						serverId: 'myServer',
						spec: '''{
							"files": [
							{
									"pattern": "addressbook.war",
									"target": "libs-snapshot-local"
								}
							]
						}''',
					)
				}
			}
		}		
		stage('Download Jfrog Artifact') {
			steps {
				dir('/tmp'){
					rtDownload (
						serverId: 'myServer',
						spec: '''{
							"files": [
							{
								"pattern": "libs-snapshot-local/",
								"target": ""
								}
							]
						}''',
					)
				}
			}
		}
==============================================================================================================*/

		stage('Build dockerimage'){
            steps {
				sh 'cp -pr /tmp/workspace/${IMAGE_NAME}/target/addressbook.war /tmp/workspace/${IMAGE_NAME}/'
				sh 'sudo chmod 666 /var/run/docker.sock'
                sh' aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com'
                sh 'docker build -t ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG} .'
                }
				post {
					success {
						sh 'echo "Image Build Successful"'
					}
					failure {
						sh 'echo "Image build failed"'
                }
            }
        }
        stage('Check Repository Existence') {
            steps {
                script {
                    def repositoryName = '${IMAGE_NAME}'
                    def repositoryExists = sh(script: "aws ecr describe-repositories --repository-names ${IMAGE_NAME} --region ${DEFAULT_REGION}", returnStatus: true) == 0
                    if (!repositoryExists) {
						 sh "aws ecr get-login-password --region ${DEFAULT_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com"
                        echo "Repository does not exist. Creating repository..."
                        sh "aws ecr create-repository --repository-name ${IMAGE_NAME} --region ${DEFAULT_REGION}"
                    } else {
                        echo "Repository already exists. Skipping creation."
                    }
                }
            }
        }
        stage('Pushing image to ECR Repository') {
            steps {
                //sh 'aws ecr create-repository --repository-name ${IMAGE_NAME} --region ${DEFAULT_REGION}'
                sh 'docker push ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}'
               }
               post {
                   success {
                       sh "echo 'Docker image pushed to ECR. Created Repository - ${IMAGE_NAME} successfully'"
                   }
                   failure {
                       sh 'echo "Pushing Image to ECR failed"'
                   }
            }
        }
        stage('Deploy to "DEV" environment'){
			agent { label 'DEV' }
            steps {
                sh 'sudo yum install -y docker; sudo systemctl start docker; sudo systemctl enable docker'
                sh 'sudo chmod 666 /var/run/docker.sock'
                sh "aws ecr get-login-password --region ${DEFAULT_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com"
                sh 'docker pull ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}'
                sh 'docker run -itd ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }
        stage('Deploy to "STAGE" environment'){
            agent { label 'STAGE' }
            steps {
                sh 'sudo yum install -y docker; sudo systemctl start docker; sudo systemctl enable docker'
                sh 'sudo chmod 666 /var/run/docker.sock'
                sh "aws ecr get-login-password --region ${DEFAULT_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com"
                sh 'docker pull ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}'
                sh 'docker run -itd ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }
    }
}
