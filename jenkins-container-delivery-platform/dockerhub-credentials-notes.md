# Docker Hub Credentials for Jenkins

The Docker Hub publishing Jenkinsfile requires two Jenkins credentials:

## Credential 1

Kind: Secret text
ID: dockerhub-username
Secret: Docker Hub namespace or username

## Credential 2

Kind: Username with password
ID: dockerhub-credentials
Username: Docker Hub username
Password: Docker Hub access token

Use a Docker Hub access token instead of an account password.

Jenkins path:

Dashboard → Manage Jenkins → Credentials → System → Global credentials → Add Credentials

The base Jenkinsfile can run without these credentials.
The Docker Hub Jenkinsfile requires these credentials before image publishing works.
