
def commitHash = checkout(scm).GIT_COMMIT

def DOCKER_REPO = "mrrestwar"



node {
    checkout scm

    def customImage = docker.build("wraith:${env.BUILD_ID}")

    customImage.inside {
        sh 'wraith info'
    }
}