pipeline {
    agent any
    tools {
        jdk 'myJDK'
        maven 'myMVN'
    }
	parameters {
         string(defaultValue: '', description: 'branch name for deploying specific vendor release version, master is latest production', name: 'branch_name')
         booleanParam(defaultValue: false, description: 'tick this to use rundeck deployment, release via PTP must use this', name: 'bool_release_build')         
         booleanParam(defaultValue: false, description: 'tick this to upload insideTrack files ONLY, director build will be skipped', name: 'bool_insideTrack_only')
         string(defaultValue: '9.8.3', description: 'previous director version', name: 'previous_director_version')
         string(defaultValue: '9.8.3', description: 'director version', name: 'director_version')
         string(defaultValue: '',  description: 'config version', name: 'config_version')
         string(defaultValue: '',  description: 'deployment ENVs, support multiple ones, use / to split e.g. DEV1/DEV2', name: 'deployment_environment')
         string(defaultValue: '',  description: 'config version', name: 'config_version')
         booleanParam(defaultValue: false, description: 'upload files to Artifactory - if choose this option, it will not do deployment but only do file upload to artifactory', name: 'bool_artifactory')
         string(defaultValue: 'generic-release/com/scb/orcid/orcid-server-9.8.3.zip',  description: 'the file path for uploading from Artifactory generic-temp to generic-release/maven-releases etc, please ensure the filename in the end (it does NOT support folder upload), used by above bool_artifactory option only)', name: 'file_path')
     }
    stages {
        stage('Compile'){
            agent any
            steps {
                git 'https://github.com/devops-trainer/DevOpsClassCodes.git'
                branch 'master'
            }
        }
        stage('CodeReview'){
            agent any
            steps{
                sh 'mvn pmd:pmd'
            }
        }
        stage('UnitTest') {
            agent any
            steps {
                sh 'mvn test'
            }
            post {
                success {
                    junit testResults: 'target/surefire-reports/*.xml'
                }
            }
        }
        stage ('Package') {
            agent any
            steps {
                sh 'mvn package'
            }
		post {
			success {
					sh 'echo "Webhooks Added"'
			}
		}
        }
    }
    post{
        success{
            sh 'echo "pipeline successful"'
        }
        failure{
            sh 'echo "Pipeline failed"'
        }
    }
}
