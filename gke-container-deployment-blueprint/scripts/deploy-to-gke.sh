#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:?PROJECT_ID is required}"
REGION="${REGION:-us-central1}"
ZONE="${ZONE:-us-central1-a}"
REPOSITORY="${REPOSITORY:-container-runtime}"
CLUSTER_NAME="${CLUSTER_NAME:-container-platform-gke}"
IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/container-runtime:v1.0"

gcloud artifacts repositories create "${REPOSITORY}" \
  --repository-format=docker \
  --location="${REGION}" \
  --description="Container runtime images" || true

gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

docker tag gke-container-runtime:v1.0 "${IMAGE_NAME}"
docker push "${IMAGE_NAME}"

gcloud container clusters get-credentials "${CLUSTER_NAME}" \
  --zone="${ZONE}" \
  --project="${PROJECT_ID}"

sed "s|PROJECT_ID|${PROJECT_ID}|g" k8s/deployment.yaml | kubectl apply -f -
kubectl apply -f k8s/service.yaml

kubectl rollout status deployment/container-runtime
kubectl get pods -o wide
kubectl get service container-runtime-service
