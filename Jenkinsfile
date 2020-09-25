def readProperties()
{

	def properties_file_path = "${workspace}" + "@script/properties.yml"
	def property = readYaml file: properties_file_path
	env.APP_NAME = property.APP_NAME
        env.MS_NAME = property.MS_NAME
        env.BRANCH = property.BRANCH
        env.GIT_SOURCE_URL = property.GIT_SOURCE_URL
        env.SCR_CREDENTIALS = property.SCR_CREDENTIALS
	env.GIT_CREDENTIALS = property.GIT_CREDENTIALS
        env.SONAR_HOST_URL = property.SONAR_HOST_URL
        env.CODE_QUALITY = property.CODE_QUALITY
        env.UNIT_TESTING = property.UNIT_TESTING
        env.CODE_COVERAGE = property.CODE_COVERAGE
        env.FUNCTIONAL_TESTING = property.FUNCTIONAL_TESTING
        env.SECURITY_TESTING = property.SECURITY_TESTING
	env.PERFORMANCE_TESTING = property.PERFORMANCE_TESTING
	env.TESTING = property.TESTING
	env.QA = property.QA
	env.PT = property.PT
	env.User = property.User
    env.DOCKER_REGISTRY = property.DOCKER_REGISTRY
    env.DOCKER_REPO=property.DOCKER_REPO
	env.mailrecipient = property.mailrecipient
	env.EXPECTED_COVERAGE = property.EXPECTED_COVERAGE
	env.IMAGE_TAG = (new Date()).format("yyMMddHHmm", TimeZone.getTimeZone('UTC'))
	
    
}



def FAILED_STAGE

node 
{
   def MAVEN_HOME = tool "MAVEN_HOME"
   def JAVA_HOME = tool "JAVA_HOME"
   env.PATH="${env.PATH};${MAVEN_HOME}\\bin;${JAVA_HOME}\\bin"
 //properties([[$class: 'BuildConfigProjectProperty', name: '', namespace: '', resourceVersion: '', uid: ''], pipelineTriggers([pollSCM('* * * * *')])])
   try{
   stage('Checkout')
   {
       FAILED_STAGE=env.STAGE_NAME
       readProperties()
       checkout([$class: 'GitSCM', branches: [[name: "*/${BRANCH}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: "${SCR_CREDENTIALS}", url: "${GIT_SOURCE_URL}"]]])
      
   }

   stage('Initial Setup')
   {   
       FAILED_STAGE=env.STAGE_NAME
           echo "${PATH}"
       //bat 'mvn clean compile'
   }
   if(env.UNIT_TESTING == 'True')
   {
   	stage('Unit Testing')
   	{
        	
        	FAILED_STAGE=env.STAGE_NAME
        	bat 'mvn -s Maven/setting test'
   	}
   }
   
    if(env.CODE_QUALITY == 'True')
   {
   	stage('Code Quality Analysis')
   	{
       		FAILED_STAGE=env.STAGE_NAME
       		bat 'mvn -s Maven/setting sonar:sonar -Dsonar.host.url="${SONAR_HOST_URL}"'
   	}
   }   
   
   if(env.CODE_COVERAGE == 'True')
   {
   	stage('Code Coverage')
   	{
		FAILED_STAGE=env.STAGE_NAME
		bat 'mvn -s Maven/setting package -Djacoco.percentage.instruction=${EXPECTED_COVERAGE}'
   	}
   }
   
  if(env.SECURITY_TESTING == 'True')
  {
	stage('Security Testing')
	{
		FAILED_STAGE=env.STAGE_NAME
		bat 'mvn -s Maven/setting findbugs:findbugs'
	}	
  }
   
   stage('Build and Tag Image for Dev')
   {
   		
        withCredentials([usernamePassword(credentialsId: 'DockerID', usernameVariable: 'username', passwordVariable: 'password')])
        {  
   		
               FAILED_STAGE=env.STAGE_NAME
               //bat 'mvn package'
               stash name:'executable', includes:'target/*,Dockerfile'
               unstash name:'executable'
                bat' @FOR /f "tokens=*" /%i IN ("docker-machine env default") DO /@%i '
               bat "docker login -u $username -p $password"
               bat "docker build -t ${MS_NAME}:latest ."
               bat "docker tag ${MS_NAME}:latest ${DOCKER_REPO}/${MS_NAME}:${IMAGE_TAG}"
               bat "docker push ${DOCKER_REPO}/${MS_NAME}:${IMAGE_TAG}"
               bat "docker rmi -f /${DOCKER_REPO}/${MS_NAME}:${IMAGE_TAG}"
               bat "docker rmi -f ${MS_NAME}:latest"
        
    
        }
	  
    
	   
   }
   

  
   
   }
	catch(e){
		echo "Pipeline has failed"
		emailext body: "${env.BUILD_URL} has result ${currentBuild.result} at stage ${FAILED_STAGE} with error" + e.toString(), subject: "Failure of pipeline: ${currentBuild.fullDisplayName}", to: "${mailrecipient}"
	    throw e
	
	}
	     
}

