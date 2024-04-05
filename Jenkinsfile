pipeline{
    agent { label 'artifactory-slave' }
    tools {
        maven 'myMVN'
        jdk 'myJDK'
        // dockerTool 'myDOCKER'
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
        }
// =============================================== Upload Jfrog Artifact ===============================================		
		stage('Upload Jfrog Artifact') {
            steps {
				dir('/tmp/workspace/artifactory-pipeline/target'){
					rtServer (
						id: 'jfrog-artifactory',
						url: 'http://3.110.55.229:8082/artifactory',
						credentialsId: 'jfrog-login',
						bypassProxy: true,
					)
					rtUpload (
						serverId: 'jfrog-artifactory',
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
		
// =============================================== Download Jfrog Artifact ===============================================
		
		stage('Download Jfrog Artifact') {
			steps {
				dir('/tmp'){
					rtDownload (
						serverId: 'jfrog-artifactory',
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
// =============================================== Build and Deploy to "DEV" ===============================================		
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
		
// =============================================== Creating Repository on ECR ===============================================
        stage('Check Repository Existence') {
            steps {
                script {
                    def repositoryName = '${DOCKER_IMAGE_NAME}'
                    def repositoryExists = sh(script: "aws ecr describe-repositories --repository-names ${DOCKER_IMAGE_NAME} --region ${AWS_DEFAULT_REGION}", returnStatus: true) == 0
                    if (!repositoryExists) {
						 sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                        echo "Repository does not exist. Creating repository..."
                        sh "aws ecr create-repository --repository-name ${DOCKER_IMAGE_NAME} --region ${AWS_DEFAULT_REGION}"
                    } else {
                        echo "Repository already exists. Skipping creation."
                    }
                }
            }
        }
// =============================================== Pushing Docker image on ECR ===============================================
        stage('Pushing to ECR from Dev') {
            steps {
                script {
                    sh "docker push ${ECR_REPOSITORY_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
				}
            }
        }
// =============================================== Depolying to another environment ===============================================
		/*stage('Deploy to "STAGE" environment') {
			agent { label 'stage' }
            steps {
                script {
					sh 'sudo chmod 666 /var/run/docker.sock'
                    // sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker pull ${ECR_REPOSITORY_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
					sh "docker run -itd -P ${ECR_REPOSITORY_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }*/
	}
    post {
		success {
            sh 'echo "Congratulations! Deployment Successful"'
            sh 'sudo docker images; sudo docker ps -a'
        }
        /*always {
            // Cleanup tasks, finalization steps, etc., <<< if required >>>
            sh 'docker stop $(docker ps -a -q)|| true'
            sh 'docker rm $(docker ps -a -q) || true'
			sh 'docker rmi -f $(docker images -a -q)|| true' 
        }*/
        failure {
            sh 'echo "Failure in execution, validate"'
		}
	}
}
