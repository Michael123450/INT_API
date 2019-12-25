//@Library('Utilities') _
import groovy.json.JsonSlurper
import hudson.model.*
def BuildVersion
def Current_version
def NextVersion
 pipeline {

     options {
         timeout(time: 30, unit: 'MINUTES')
     }
    environment {
    registry = "rozdockerforever/dev"
    registryCredential = 'dockerhub'
    //dockerImage = ''
    }
     agent { label 'jenny_slave' }
     stages {
         stage('Checkout') {
             steps {
                 script {
                   //  node('master'){
                       //  dir('Release') {
                        //     deleteDir()
                        //     checkout([$class: 'GitSCM', branches: [[name: 'Prod']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git-cred-id', url: "https://github.com/intclassproject/Release.git"]]])
                     //        path_json_file = sh(script: "pwd", returnStdout: true).trim() + '/' + 'Prod' + '.json'
                         //    Current_version = Return_Json_From_File("$path_json_file").release.services.intapi.version
                         //}
                  //   }
                     
                     dir('INT_API') {
                         deleteDir()
                         checkout([$class: 'GitSCM', branches: [[name: 'Dev']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git_rd_cred', url: 'https://github.com/roz-Devops/INT_API.git']]])
                  //       Commit_Id = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                         BuildVersion = '1.0.0'
                    //     last_digit_current_version = sh(script: "echo $Current_version | cut -d'.' -f3", returnStdout: true).trim()
                    //     NextVersion = sh(script: "echo $Current_version | cut -d. -f1", returnStdout: true).trim() + '.' + sh(script: "echo $Current_version |cut -d'.' -f2", returnStdout: true).trim() + '.' + (Integer.parseInt(last_digit_current_version) + 1)
                         println("Checking the build version: $BuildVersion")

                     }
                 }
             }
         }
         stage('UT') {
             steps {
                 println('Will be added soon ')

             }
         }
         stage('Build') {
             steps {
                 script {
                     dir('INT_API') {
                      sh "ls"
                      sh "pwd"                   
                      try {
                          //docker.build("intapi:$BuildVersion")
                  //     sh "sudo chmod 777 Dockerfile"
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
         }
         stage('Push image to repository'){
             steps{
                 script{
                     try{
                         withCredentials([usernamePassword(credentialsId: 'mkl88', passwordVariable: 'toy2017**', usernameVariable: 'DOCKER_USERNAME')]) {
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
     //    stage('Triggering E2E-CI job'){
            
//steps{
            //         script{
             //            node('master'){
              //               build job: 'E2E-CI', parameters: [ string(name: 'triggered_by', value: 'intapi'), string(name:'next_version', value: NextVersion), string(name: 'Image_version', value: 'int_api_' + BuildVersion)]
                            
                 //        }


                 //   }
  //         }

  ///       }

     }
 }
def Return_Json_From_File(file_name){
    return new JsonSlurper().parse(new File(file_name))
}
