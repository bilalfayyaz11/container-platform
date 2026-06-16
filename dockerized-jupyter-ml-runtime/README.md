# Dockerized Jupyter Machine Learning Runtime

## What This Does

This implementation provides a reproducible Docker-based machine learning runtime using Jupyter, Python data science libraries, persistent storage, and a custom container image. It builds a complete workflow for generating data, training a Random Forest classifier, saving model artifacts, exporting visual reports, and validating model reload behavior after container restart.

The environment solves the common machine learning reliability issue where notebooks and models behave differently across machines because of mismatched Python versions, package versions, or missing dependencies. By packaging the runtime inside Docker and storing outputs through mounted volumes, the workflow becomes repeatable, portable, and suitable for team-based ML development.

This design is useful for MLOps, AI infrastructure, platform engineering, and data science enablement teams that need consistent experimentation environments before moving workloads into production pipelines.

## Architecture

    +--------------------------------------------------+
    | Host Machine                                     |
    | Ubuntu 24.04                                     |
    | ~/ml-docker-workspace                            |
    +----------------------+---------------------------+
                           |
                           | Docker volume mount
                           v
    +--------------------------------------------------+
    | Docker Runtime                                   |
    | jupyter-ml-runtime                               |
    | Port: 8888                                       |
    | Image: jupyter-ml-runtime:latest                 |
    +----------------------+---------------------------+
                           |
                           v
    +--------------------------------------------------+
    | Jupyter + ML Environment                         |
    | TensorFlow                                       |
    | Scikit-learn                                     |
    | Pandas / NumPy                                   |
    | Matplotlib / Seaborn / Plotly                    |
    | Joblib                                           |
    +----------------------+---------------------------+
                           |
                           v
    +--------------------------------------------------+
    | ML Workflow                                      |
    | Synthetic classification dataset                 |
    | Random Forest training                           |
    | Model evaluation                                 |
    | Feature importance analysis                      |
    | Model reload validation                          |
    +----------------------+---------------------------+
                           |
                           v
    +--------------------------------------------------+
    | Persistent Artifacts                             |
    | data/synthetic_classification_dataset.csv        |
    | models/random-forest-classifier.joblib           |
    | models/model-metadata.json                       |
    | reports/*.txt / *.json / *.png / *.csv           |
    +--------------------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker CLI access for the current user
- Git
- curl
- tree
- Internet access for pulling base images and installing Python packages

## Setup & Installation

sudo apt update

sudo apt install -y git curl tree docker.io

sudo systemctl enable --now docker

sudo usermod -aG docker $USER

newgrp docker

docker --version

docker info

## How to Reproduce

Create the working directory:

mkdir -p ~/ml-docker-workspace/{notebooks,data,models,reports}

cd ~/ml-docker-workspace

Pull the base Jupyter image:

docker pull jupyter/base-notebook:latest

Inspect the base image:

docker inspect jupyter/base-notebook:latest > jupyter-base-notebook-inspect.json

docker history jupyter/base-notebook:latest > jupyter-base-notebook-history.txt

Run the base Jupyter container:

docker rm -f jupyter-ml-workspace 2>/dev/null || true

docker run -d \
  --name jupyter-ml-workspace \
  -p 8888:8888 \
  -v ~/ml-docker-workspace:/home/jovyan/work \
  -e JUPYTER_ENABLE_LAB=yes \
  jupyter/base-notebook:latest

Install the machine learning dependencies inside the runtime:

docker exec jupyter-ml-workspace bash -lc '
pip install --upgrade pip
pip install --no-cache-dir tensorflow scikit-learn pandas numpy matplotlib seaborn plotly ipywidgets joblib
'

Run the training workflow:

docker exec jupyter-ml-workspace python /home/jovyan/work/notebooks/ml-container-training.py

Validate generated artifacts:

tree -a ~/ml-docker-workspace

cat ~/ml-docker-workspace/models/model-metadata.json

cat ~/ml-docker-workspace/reports/model-load-validation.json

Build the custom runtime image:

docker build -t jupyter-ml-runtime:latest .

Run the custom runtime container:

docker rm -f jupyter-ml-workspace 2>/dev/null || true

docker rm -f jupyter-ml-runtime 2>/dev/null || true

docker run -d \
  --name jupyter-ml-runtime \
  -p 8888:8888 \
  -v ~/ml-docker-workspace:/home/jovyan/work \
  -e JUPYTER_ENABLE_LAB=yes \
  jupyter-ml-runtime:latest

Verify runtime libraries:

docker exec jupyter-ml-runtime python - << 'PY'
import tensorflow as tf
import sklearn
import pandas as pd
import numpy as np
import matplotlib
import seaborn
import plotly
import joblib

print("TensorFlow:", tf.__version__)
print("Scikit-learn:", sklearn.__version__)
print("Pandas:", pd.__version__)
print("NumPy:", np.__version__)
print("Matplotlib:", matplotlib.__version__)
print("Seaborn:", seaborn.__version__)
print("Plotly:", plotly.__version__)
print("Joblib: OK")
PY

## Tools Used

- Docker
- Jupyter
- Python
- TensorFlow
- Scikit-learn
- Pandas
- NumPy
- Matplotlib
- Seaborn
- Plotly
- Joblib
- Bash
- Linux
- Git
- tree

## Key Skills Demonstrated

- Dockerized machine learning runtime design
- Jupyter environment containerization
- Persistent model storage with Docker volumes
- Reproducible custom image creation
- Python dependency management inside containers
- Model training and evaluation automation
- Artifact generation for ML workflows
- Runtime validation after container restart
- MLOps-ready development environment design
- AI infrastructure and platform engineering fundamentals

## Real-World Use Case

A data science or AI platform team can use this pattern to give every engineer the same isolated machine learning workspace without manually configuring Python, Jupyter, TensorFlow, or Scikit-learn on each machine. The same approach can be extended into internal developer platforms, shared GPU workstations, CI-based model validation, or Kubernetes-hosted notebook environments where reproducibility and artifact persistence are required.

## Lessons Learned

- Installing packages manually inside a running container is fast for experimentation but not reliable for repeatable engineering workflows.
- Docker volumes are essential for preserving notebooks, datasets, models, and reports after containers are restarted or replaced.
- Modern Jupyter images change over time, so image tags and dependency validation are important for stable ML environments.
- Model persistence must be tested by reloading the saved model, not just by checking that a file exists.
- Custom images provide a cleaner foundation for team use because dependencies are baked into the runtime.

## Troubleshooting Log

Issue:
The base image was referenced without a pinned tag, which means Docker pulls the moving latest image.

Resolution:
Used jupyter/base-notebook:latest explicitly and captured image inspection plus history output for runtime visibility.

Issue:
TensorFlow 2.13.0 can fail in modern Python environments because current Jupyter images may use newer Python versions.

Resolution:
Installed TensorFlow without forcing the outdated version so pip could resolve a compatible release for the container Python runtime.

Issue:
The package name jupyter-widgets is incorrect for modern Python/Jupyter environments.

Resolution:
Used ipywidgets instead.

Issue:
The command jupyter nbextension enable --py widgetsnbextension is outdated for modern JupyterLab-based images.

Resolution:
Removed the command from the custom Dockerfile and relied on ipywidgets support in the current JupyterLab stack.

Issue:
Runtime evidence files were created inside ~/ml-docker-workspace, but the first verification command looked for them in /home/ubuntu.

Resolution:
Verified the files from the correct working directory and tracked them as part of the persistent workspace.

Issue:
Interactive notebook creation can waste time and may save files in the wrong path.

Resolution:
Created a reproducible Python training workflow under notebooks/ml-container-training.py to generate the same ML outputs consistently from the terminal.

Issue:
Container-level package installation is temporary if the container is rebuilt.

Resolution:
Created a custom Docker image named jupyter-ml-runtime:latest with ML dependencies preinstalled.
