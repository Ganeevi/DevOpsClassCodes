pipeline {
    tools {
        maven 'myMVN'
        jdk 'myJDK'
    }
    agent {label 'Mumbai-Jenkins-Slave' }
    stages {
        stage ('Checkout') {
            //agent any
            steps {
                git 'https://github.com/Ganeevi/DevOpsClassCodes.git'
            }
        }
        stage ('Compile') {
            //agent any
            steps {
                sh 'mvn compile'
            }    
        }
        stage ('Code_Review') {
            //agent any
            steps {
                sh 'mvn pmd:pmd'
            }
        }
        stage ('Unit_Test') {
            //agent any
            steps {
                sh 'mvn test'
            }
        }
        stage ('Package') {
            //agent any
            steps {
                sh 'mvn package'
            }
        }
        stage ('Docker_Installation') {
            steps {
                sh 'sudo yum install -y docker'
                sh 'sudo systemctl start docker'
                sh 'sudo systemctl enable docker'
            }
        }
        /*stage ('Deploy') {
            //agent any
            steps {
                sh 'sudo sh docker_inst.sh'
            }
        }*/
    }
}
