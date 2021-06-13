FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04

ARG CONDA_PYTHON_VERSION=3
ARG CONDA_DIR=/opt/conda
ARG JUPYTERLAB_NAME=torch3d_lab

# Instal basic utilities
RUN apt-get update \
    && apt-get update \ 
    && apt-get upgrade -y \

    && apt install -qy libglib2.0-0 \
    && apt install -y openssh-server \
    && apt-get install -y --no-install-recommends git wget curl g++ cmake unzip bzip2 build-essential ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download miniconda + install it. 
ENV PATH $CONDA_DIR/bin:$PATH
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda$CONDA_PYTHON_VERSION-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh \
    && echo "conda activate base" >> ~/.bashrc \
    && /bin/bash /tmp/miniconda.sh -b -p $CONDA_DIR \
    && apt-get clean \
    && rm -rf /tmp/*  \
    && rm -rf /var/lib/apt/lists/* 

COPY base_conda.yml /tmp/base_conda.yml

#Update the base conda env. with PyTorch 1.7.1 +PyTorch3D.
RUN conda update --all \
    && conda env update -f /tmp/base_conda.yml \
    && rm /tmp/base_conda.yml

#JupyterLab extension. 
RUN jupyter labextension install @jupyterlab/toc \
    && jupyter lab build --name=$JUPYTERLAB_NAME \
    && jupyter nbextension enable --py neptune-notebooks





