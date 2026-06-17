# Docker Hub Publishing Readiness

## Required External Setup

A Docker Hub repository must exist before the publish job can push images.

Recommended repository name:

github-actions-container-pipeline

## Required GitHub Repository Secrets

Set these repository secrets before running the publish job:

- DOCKER_USERNAME
- DOCKER_PASSWORD

Use a Docker Hub access token for DOCKER_PASSWORD instead of an account password.

## Validation Path

1. Push the repository to GitHub.
2. Open the repository in GitHub.
3. Go to Settings.
4. Open Secrets and variables.
5. Select Actions.
6. Add DOCKER_USERNAME.
7. Add DOCKER_PASSWORD.
8. Push a commit to main.
9. Confirm the build-test-and-package job passes.
10. Confirm the publish-image job pushes the image to Docker Hub.

## Expected Image Tags

The workflow creates multiple image tags:

- latest
- main
- main-<commit-sha>

## Security Notes

Do not commit Docker Hub credentials to the repository.

Do not use a personal account password when an access token is available.

Rotate the token if it is ever exposed.
