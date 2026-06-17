# Docker Hub Publishing Secrets

The image publishing job requires two GitHub repository secrets:

- DOCKER_USERNAME
- DOCKER_PASSWORD

Use a Docker Hub access token instead of an account password.

Secret configuration path:

GitHub repository → Settings → Secrets and variables → Actions → New repository secret

The workflow can build and test containers without Docker Hub secrets. The publish job requires these secrets before the image can be pushed.
