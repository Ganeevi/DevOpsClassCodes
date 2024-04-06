// Issues to be fixed: install JFROG on Amazon Linux 2 rather than ubuntu, as different java - jdk versions gives issues.

pipeline {
    agent { label 'docker-jfrog' }
	/* Steps:
		1. Install 1 Jenkins Master (Packages: Java-JDK, Git, jenkins)
		2. Install 1 Ubuntu Jfrog server (Packages: JDK, GIT, docker, jfrog)
		3. Install 2 Jenkins Slaves (Packages: Java-JDK, docker, git)
		4. Open ssh connection between all
		5. Assign a role for access to ECR.
				1. Jenkins Master will execute all the jobs on Ubuntu server
				2. Ubuntu agent tasks will be executing MVN goles, build dockerimage from dockerfile and upload the image on ECR,  and uploading the artifacts to the jfrog artifactory.
				3. Once image is created, it will be pulled from the artifactory and containers will be created on Jenkins Slaves.
	*/
    tools {
        jdk 'myJDK'         // JDK "JAVA_HOME" defination of "ubuntu server in Jenkins tools"
        maven 'myMVN'
    }
    environment {
        ACCOUNT_ID = "533267022876"
		DEFAULT_REGION = "ap-south-1"
		DOCKER_IMAGE = "${JOB_NAME}"
		IMAGE_TAG = "${BUILD_NUMBER}"
    }
    stages {
        stage('Checkout'){
            steps {
                git 'https://github.com/Ganeevi/DevOpsClassCodes.git'
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
                    sh 'cd /tmp/workspace/${JOB_NAME}/; cp -pr target/addressbook.war .'
                    sh 'ls -l /tmp/workspace/${JOB_NAME}/'
                    //sh 'sudo yum install -y docker; sudo systemctl start docker; sudo systemctl enable docker'
                }
            }
        }
// =============================================== Jfrog Artifact ===============================================
		/*stage('Upload Jfrog Artifact') {
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
		}*/
// =============================================== Jfrog Artifact ===============================================
		stage('Creating dockerimage from dockerfile'){
            steps {
				sh 'sudo chmod 666 /var/run/docker.sock'
                sh' aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com'
                sh 'docker build -t ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${DOCKER_IMAGE}:${IMAGE_TAG} .'
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
                    def repositoryName = '${DOCKER_IMAGE}'
                    def repositoryExists = sh(script: "aws ecr describe-repositories --repository-names ${DOCKER_IMAGE} --region ${DEFAULT_REGION}", returnStatus: true) == 0
                    if (!repositoryExists) {
						 sh "aws ecr get-login-password --region ${DEFAULT_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com"
                        echo "Repository does not exist. Creating repository..."
                        sh "aws ecr create-repository --repository-name ${DOCKER_IMAGE} --region ${DEFAULT_REGION}"
                    } else {
                        echo "Repository already exists. Skipping creation."
                    }
                }
            }
        }
        stage('Pushing image to ECR Repository') {
            steps {
                //sh 'aws ecr create-repository --repository-name ${DOCKER_IMAGE} --region ${DEFAULT_REGION}'
                sh 'docker push ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${DOCKER_IMAGE}:${IMAGE_TAG}'
               }
               post {
                   success {
                       sh "echo 'Docker image pushed to ECR. Created Repository - ${DOCKER_IMAGE} successfully'"
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
                sh 'docker pull ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${DOCKER_IMAGE}:${IMAGE_TAG}'
                sh 'docker run -itd ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${DOCKER_IMAGE}:${IMAGE_TAG}'
            }
        }
        stage('Deploy to "STAGE" environment'){
            agent { label 'STAGE' }
            steps {
                sh 'sudo yum install -y docker; sudo systemctl start docker; sudo systemctl enable docker'
                sh 'sudo chmod 666 /var/run/docker.sock'
                sh "aws ecr get-login-password --region ${DEFAULT_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com"
                sh 'docker pull ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${DOCKER_IMAGE}:${IMAGE_TAG}'
                sh 'docker run -itd ${ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/${DOCKER_IMAGE}:${IMAGE_TAG}'
            }
        }
    }
}
