#!/bin/bash

set -e

JENKINS_CONTAINER="container-cicd-jenkins"
JOB_NAME="container-cicd-node-pipeline"

docker exec "$JENKINS_CONTAINER" mkdir -p /var/jenkins_home/jobs/$JOB_NAME

docker exec "$JENKINS_CONTAINER" tee /var/jenkins_home/jobs/$JOB_NAME/config.xml > /dev/null << 'XML'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job">
  <actions/>
  <description>Docker-based CI/CD pipeline for a containerized Node.js service.</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps">
    <script>
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'container-cicd-node-service'
        DOCKER_TAG = "${BUILD_NUMBER}"
        TEST_CONTAINER = "container-cicd-test-${BUILD_NUMBER}"
        PROD_CONTAINER = 'container-cicd-prod'
    }

    stages {
        stage('Checkout') {
            steps {
                dir('/workspace/sample-app') {
                    sh 'ls -la'
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('/workspace/sample-app') {
                    sh '''
                        npm ci
                        npm test
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('/workspace/sample-app') {
                    sh '''
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker build -t ${DOCKER_IMAGE}:latest .
                        docker images | grep ${DOCKER_IMAGE}
                    '''
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                sh '''
                    docker rm -f ${TEST_CONTAINER} 2>/dev/null || true

                    docker run -d \
                      --name ${TEST_CONTAINER} \
                      -p 3001:3000 \
                      ${DOCKER_IMAGE}:${DOCKER_TAG}

                    sleep 8

                    curl -f http://localhost:3001/health
                    curl -f http://localhost:3001/

                    docker logs ${TEST_CONTAINER} --tail 20
                '''
            }
            post {
                always {
                    sh 'docker rm -f ${TEST_CONTAINER} 2>/dev/null || true'
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    docker rm -f ${PROD_CONTAINER} 2>/dev/null || true

                    docker run -d \
                      --name ${PROD_CONTAINER} \
                      -p 3000:3000 \
                      --restart unless-stopped \
                      ${DOCKER_IMAGE}:${DOCKER_TAG}

                    sleep 5

                    curl -f http://localhost:3000/health
                    docker ps --filter "name=${PROD_CONTAINER}"
                '''
            }
        }
    }

    post {
        success {
            echo 'Container CI/CD pipeline completed successfully.'
        }
        failure {
            echo 'Container CI/CD pipeline failed.'
        }
    }
}
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
XML

docker exec "$JENKINS_CONTAINER" chown -R jenkins:jenkins /var/jenkins_home/jobs/$JOB_NAME
docker exec "$JENKINS_CONTAINER" java -jar /usr/share/jenkins/jenkins.war --version >/dev/null 2>&1 || true
docker restart "$JENKINS_CONTAINER"

echo "Created Jenkins job: $JOB_NAME"
echo "Open Jenkins at http://localhost:8080 and run the job manually if needed."
