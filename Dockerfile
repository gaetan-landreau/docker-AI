FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04

ARG CONDA_PYTHON_VERSION=3
ARG CONDA_DIR=/opt/conda
ARG JUPYTERLAB_NAME=3d_lab

#####################################################################
# Instal basic utilities + create an external dir. for any lib. tools. 
######################################################################
RUN apt-get update \
    && apt-get update \ 
    && apt-get upgrade -y \
    && apt install -qy libglib2.0-0 \
    && apt install -y openssh-server \
    && apt-get install -y --no-install-recommends git wget curl g++ cmake unzip bzip2 build-essential ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \

    && mkdir external 

##################################
# Download miniconda + install it. 
##################################
ENV PATH $CONDA_DIR/bin:$PATH
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda$CONDA_PYTHON_VERSION-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh \
    && echo "conda activate base" >> ~/.bashrc \
    && /bin/bash /tmp/miniconda.sh -b -p $CONDA_DIR \
    && apt-get clean \
    && rm -rf /tmp/*  \
    && rm -rf /var/lib/apt/lists/* 



############################################################
#Update the base conda env. with the corresponding YAML file. 
############################################################
COPY base_conda.yml /tmp/base_conda.yml
RUN conda update --all \
    && conda env update -f /tmp/base_conda.yml \
    && rm /tmp/base_conda.yml \ 

    #Also install JupyterLab extension in this base env.
    && jupyter labextension install @jupyterlab/toc \
    && jupyter lab build --name=$JUPYTERLAB_NAME \
    && jupyter nbextension enable --py neptune-notebooks


###############################################
# Create the conda env. for PyTorch + PyTorch3D
###############################################
COPY pytorch_conda.yml /tmp/pytorch_conda.yml
RUN conda create -f /tmp/pytorch_conda.yml --clone base_conda
SHELL ["conda","run","-n","pytorch","/bin/bash","-c"]
RUN python -m ipykernel install --name kernel_one --display-name "PyTorch"
    && rm /tmp/pytorch_conda.yml \ 

############################################################
# Create the conda env. for TensorFlow + TensorFlow Graphics
############################################################
COPY tensorflow_conda.yml /tmp/tensorflow_conda.yml
RUN conda create -f /tmp/tensorflow_conda.yml --clone base_conda
SHELL ["conda","run","-n","tensorflow","/bin/bash","-c"]
RUN python -m ipykernel install --name kernel_one --display-name "TensorFlow"
    && rm /tmp/tensorflow_conda.yml \




