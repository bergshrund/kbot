pipeline {
    agent any
    
    environment {
        REPO = 'https://github.com/bergshrund/kbot'
        BRANCH = 'main'
        
    }

    stages {
        stage('clone') {
            steps {
                echo 'CLONE REPOSITORY'
                  git branch: "${BRANCH}", url: "${REPO}"
            }
        }
    
        stage('test') {
            steps {
                echo 'TEST EXECUTION STARTED'
                sh 'make test'
            }
        }
        
        stage('build') {
            steps {
                echo 'BUILD EXECUTION STARTED'
                sh 'make build'
            }
        }
        
        stage('image') {
            steps {
                echo 'BUILD DOCKER IMAGE STARTED'
                sh 'make image'
            }
        }
        
        
        stage('push') {
            steps {
                script {    
                    docker.withRegistry('', 'dockerhub') {
                    sh 'make push'
                    }
                }
            }
        }
    }
    
}