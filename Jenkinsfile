#!groovy

@Library("ucp-global-library") _

def runMode = "${env.RUN_MODE}"
def config = "${env.CONFIG}"

def gitBranch = "${env.BRANCH_NAME}"
def credentialsId = 'c35e98d4-5b20-4607-854e-ddc6f0fd8ba4'
def gitHubRepoUrl = 'https://github.optum.com/gendo/wraith.git'

def DOCKER_REPO = "wraith"

def CONTAINER_ID = "${BUILD_TAG}".replaceAll(" ", "_")

node {
    stage('GiT Clone') {

        // Checkout source code from CodeHub branch
        git branch: gitBranch, credentialsId: credentialsId, url: gitHubRepoUrl
        stash name: 'source'

    }
    
	stage ('Build') {
		if (runMode.equalsIgnoreCase("build")) {
			withUsernameAndPassword(credentialsId, 'MAVEN_USER', 'MAVEN_PASS') {
				withEnv(["PATH+=${tool 'docker'}"]) {
					sh "gem build wraith.gemspec"

					def DOCKER_IMAGE_PATH = "docker.optum.com/${env.DOCKER_ORG}/${DOCKER_REPO}:${DOCKER_REPO}-${env.BUILD_ID}-${env.BRANCH_NAME}"
					sh "docker build --force-rm --no-cache --pull --rm=true -t ${DOCKER_IMAGE_PATH} -t docker.optum.com/${env.DOCKER_ORG}/${DOCKER_REPO}:latest ."
					sh "docker login -u ${env.MAVEN_USER} -p ${env.MAVEN_PASS} docker.optum.com"
					sh "echo 'DOCKER_IMAGE_PATH :${DOCKER_IMAGE_PATH}'"
					sh "docker push ${DOCKER_IMAGE_PATH}"
					sh "docker push docker.optum.com/${env.DOCKER_ORG}/${DOCKER_REPO}:latest"
				}
			}
		}
	}
	stage ('Build Baseline') {
		if (runMode.equalsIgnoreCase("history")) {
			withUsernameAndPassword(credentialsId, 'MAVEN_USER', 'MAVEN_PASS') {
				withEnv(["PATH+=${tool 'docker'}"]) {
					sh "workspace=`pwd`"
					sh "ls -al configs"
					sh "docker run -d -P --name='${CONTAINER_ID}' -v '${workspace}:/wraithy' -w='/wraithy' docker.optum.com/${env.DOCKER_ORG}/${DOCKER_REPO} history ${config}"
					sh "docker logs --follow ${CONTAINER_ID}"
				}
			}
		}
	}
	stage ('Info') {
		if (runMode.equalsIgnoreCase("build") || runMode.equalsIgnoreCase("info")) {
			withUsernameAndPassword(credentialsId, 'MAVEN_USER', 'MAVEN_PASS') {
				withEnv(["PATH+=${tool 'docker'}"]) {
					sh "docker run -d -P --name='${CONTAINER_ID}-info' docker.optum.com/${env.DOCKER_ORG}/${DOCKER_REPO} info"
					sh "docker logs --follow ${CONTAINER_ID}-info"

					sh "docker run -d -P --name='${CONTAINER_ID}-validate' -v '${workspace}:/wraithy' -w='/wraithy' docker.optum.com/${env.DOCKER_ORG}/${DOCKER_REPO} validate ${config}"
					sh "docker logs --follow ${CONTAINER_ID}-validate"				}
			}
		}
	}
}