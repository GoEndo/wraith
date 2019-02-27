#!groovy

@Library("ucp-global-library") _

def gitBranch = "${env.BRANCH_NAME}"
def credentialsId = 'c35e98d4-5b20-4607-854e-ddc6f0fd8ba4'
def gitHubRepoUrl = 'https://github.optum.com/gendo/wraith.git'

def DOCKER_REPO = "wraith"



node {
    stage('GiT Clone') {

        // Checkout source code from CodeHub branch
        git branch: gitBranch, credentialsId: credentialsId, url: gitHubRepoUrl
        stash name: 'source'

    }

    stage ('Build') {
    	withUsernameAndPassword(credentialsId, 'MAVEN_USER', 'MAVEN_PASS') {
			withEnv(["PATH+=${tool 'docker'}"]) {

				def DOCKER_IMAGE_PATH = "docker.optum.com/${env.DOCKER_ORG}/${DOCKER_REPO}:${DOCKER_REPO}-${env.BUILD_ID}-${env.BRANCH_NAME}"
				sh "docker build --force-rm --no-cache --pull --rm=true -t ${DOCKER_IMAGE_PATH} -t docker.optum.com/${env.DOCKER_ORG}/${DOCKER_REPO}:latest ."
				sh "docker login -u ${env.MAVEN_USER} -p ${env.MAVEN_PASS} docker.optum.com"
				sh "echo 'DOCKER_IMAGE_PATH :${DOCKER_IMAGE_PATH}'"
				sh "docker push docker.optum.com/${env.DOCKER_ORG}/${DOCKER_REPO}"
				
				sh "docker run -P ${env.DOCKER_ORG}/${DOCKER_REPO} info"
			}
		}
    }
}