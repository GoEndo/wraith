
def gitBranch = "${env.BRANCH_NAME}"
def credentialsId = 'c35e98d4-5b20-4607-854e-ddc6f0fd8ba4'
def gitHubRepoUrl = 'https://github.optum.com/gendo/wraith.git'

def DOCKER_REPO = "mrrestwar"



node {
    stage('GiT Clone') {

        // Checkout source code from CodeHub branch
        git branch: gitBranch, credentialsId: credentialsId, url: gitHubRepoUrl
        stash name: 'source'

    }

    stage ('Build') {
		def customImage = docker.build("wraith:${env.BUILD_ID}")

		customImage.inside {
			sh 'wraith info'
		}
    }
}