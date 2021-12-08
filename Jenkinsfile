pipeline {
    agent {
        docker { image 'gradle:4.0' }
    }
    stages {
        stage('Test') {
            steps {
                sh 'gradle testAllXslt'
            }
        }
    }
}
