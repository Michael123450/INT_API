//@Library('Utilities') _
import groovy.json.JsonSlurper
import hudson.model.*
def BuildVersion
def Current_version
def NextVersion
def colons = ':'
def module = 'intapi'
def underscore = '_'
def path_json_file

 pipeline {
   options {
      timeout(time: 30, unit: 'MINUTES')
      }
    registry = "michael123450/Dev"
    registryCredential = 'dockerhub'
    agent {label 'slave'}
    stages {
        stage ('Checkout') {
            steps {
                node('master'){
                    script {
                        dir('INT_API'){
                            deleteDir()
                            checkout([$class: 'GitSCM', branches: [[name: 'Dev']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git-cred', url: "https://github.com/Michael123450/INT_API.git"]]])
                            Commit_Id = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                            BuildVersion = Current_version + '_' + Commit_Id
                            last_digit_current_version = sh(script: "echo $Current_version | cut -d'.' -f3", returnStdout: true).trim()
                            NextVersion = sh(script: "echo $Current_version | cut -d. -f1", returnStdout: true).trim() + '.' + sh(script: "echo $Current_version |cut -d'.' -f2", returnStdout: true).trim() + '.' + (Integer.parseInt(last_digit_current_version) + 1)
                        }
                        dir('Release') {
                            deleteDir()
                            checkout([$class: 'GitSCM', branches: [[name: 'master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git-cred', url: "https://github.com/Michael123450/Release.git"]]])
                            path_json_file = sh(script: "pwd", returnStdout: true).trim() + '/' + 'dev' + '.json'
                            Current_version = Return_Json_From_File("$path_json_file").Services.INT_API
                        }
                    }
                }
            }
        }
        stage ('build') {
            steps {
                script {
                        dir {'INT_API'}
                            try{
                                sh 'ls'
                                sh 'pwd'
                                sh "sudo docker build -t intapi:$BuildVersion ."
                                println("The build image is successfully")
                            }
                            catch (exception) {
                                println "The image build is failed"
                                currentBuild.result = 'FAILURE'
                                throw exception
                                }
                }
            }
        } 
        stage('Push image to repository'){
             steps{
                 script{
                     try{
                         withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                                sh "docker login -u=${DOCKER_USERNAME} -p=${DOCKER_PASSWORD}"
                                sh "docker tag intapi:$BuildVersion $registry:intapi_$BuildVersion"
                                sh "docker push $registry:intapi_$BuildVersion"      
                         }
                        }
                     catch (exception){
                         println "The image pushing to dockehub  failed"
                         currentBuild.result = 'FAILURE'
                         throw exception
                     }
                 }
             }
        }
        stage ('Update version'){
            steps{
                script{
                    node('master'){
                        dir('Release') {
                            deleteDir()
                            checkout([$class: 'GitSCM', branches: [[name: 'master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git-cred', url: "https://github.com/lidorabo/Release.git"]]])
                            path_json_file = sh(script: "pwd", returnStdout: true).trim() + '/' + 'dev' + '.json'
                            Current_version = Return_Json_From_File("$path_json_file").Services.INT_API

                        }
                    node('master'){
                        dir('Release'){
                            withCredentials([usernamePassword(credentialsId: 'git-cred', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                                sh""""
                         git config --global user.name "michael123450"
                         git config --global user.email "michael.kadosh@gmail.com"                         
                         sed -i  -r 's/("INT_API")(\\s+\\:\\s+)(.*)/\\1\\2"$NextVersion"/' $path_json_file
                         git add .
                         git commit -m "next version of INT_API is updated to $NextVersion in dev.json file"
                         git push  https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Michael123450/Release.git HEAD:master 
                            """
                            }
                        }
                    }
                }
            }
        }
        stage('Pubilsh'){
            steps{
                script{
                    node('master'){
                        dir('INT_API'){
                            withCredentials([usernamePassword(credentialsId: 'git-cred', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                                sh """
                         git config --global user.name "Michael123450"
                         git config --global user.email "michael.kadosh@gmail.com"
                         git tag -a $NextVersion -m "Tag for release version of INT_API module"
                         git push  https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Michael123450/INT_API.git $NextVersion
                            """
                            }
                        }
                        
                    }
                }
            }
    }
def Return_Json_From_File(file_name){
    return new JsonSlurper().parse(new File(file_name))
}
    


