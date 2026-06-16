FROM jupyter/base-notebook:latest

LABEL maintainer="Bilal Fayyaz"
LABEL purpose="containerized-ml-jupyter-runtime"

WORKDIR /home/jovyan

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

USER jovyan

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    tensorflow \
    scikit-learn \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    plotly \
    ipywidgets \
    joblib

EXPOSE 8888

CMD ["start-notebook.py"]
