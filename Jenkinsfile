pipeline {
    agent none
    stages {
        stage('AppBuild') {
            agent {
                docker {
                    image 'maven:3-alpine'
                    args '-v $WORKSPACE/.m2:/root/.m2 -u 1000'
                }

            }
            steps {
                sh 'mvn install'
            }
        }
        stage('ImageBuild&Push') {
            agent any
            options {
                skipDefaultCheckout(true)
            }
            steps {
		script {
			withDockerRegistry(credentialsId: 'dockerhub') 
                       {
                       def customImage = docker.build("rkdockerking/gamutkart:${BUILD_NUMBER}")
                       customImage.push()                      
                       }
              }

            }
        }
        stage('DeployApp') {
            agent any
            options {
                skipDefaultCheckout(true)
            }
            steps {
                script {
                    sshPublisher(
                            publishers:
                                    [
                                            sshPublisherDesc(
                                                    configName: 'RemoteHost1',
                                                    transfers: [
                                                            sshTransfer
                                                                    (
                                                                            sourceFiles: 'deploy.sh',
                                                                            patternSeparator: '[, ]+', 
                                                                            execCommand: 'chmod +x deploy.sh && sudo ./deploy.sh ${BUILD_NUMBER}',
                                                                            execTimeout: 120000

                                                                    )
                                                    ]
                                            )
                                    ]
                    )
                }
            }
        }
        stage('LocalCleanUp') {
            agent any
            options {
                skipDefaultCheckout(true)
            }
            steps {
                sh 'docker rmi rkdockerking/gamutkart:${BUILD_NUMBER}'
            }
        }
    }
    triggers {
        pollSCM('H/1 * * * * ')
    }
}
