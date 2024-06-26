# The base-deps Docker image installs main libraries needed to run Ray

# The GPU options are NVIDIA CUDA developer images.
ARG BASE_IMAGE="ubuntu:focal"
FROM ${BASE_IMAGE}
# FROM directive resets ARG
ARG BASE_IMAGE
# If this arg is not "autoscaler" then no autoscaler requirements will be included
ARG AUTOSCALER="autoscaler"
ENV TZ=America/Los_Angeles
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
# TODO(ilr) $HOME seems to point to result in "" instead of "/home/ray"
ENV PATH "/home/ray/anaconda3/bin:$PATH"
ARG DEBIAN_FRONTEND=noninteractive
ARG PYTHON_VERSION=3.8.16
ARG HOSTTYPE=${HOSTTYPE:-x86_64}

ARG RAY_UID=1000
ARG RAY_GID=100

RUN apt-get update -y \
    && apt-get install -y sudo tzdata \
    && useradd -ms /bin/bash -d /home/ray ray --uid $RAY_UID --gid $RAY_GID \
    && usermod -aG sudo ray \
    && echo 'ray ALL=NOPASSWD: ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

USER $RAY_UID
ENV HOME=/home/ray

SHELL ["/bin/bash", "-c"]
RUN sudo apt-get update -y && sudo apt-get upgrade -y \
    && sudo apt-get install -y \
        git \
        libjemalloc-dev \
        wget \
        cmake \
        g++ \ 
        zlib1g-dev \
        $(if [ "$AUTOSCALER" = "autoscaler" ]; then echo \
        tmux \
        screen \
        rsync \
        netbase \
        openssh-client \
        gnupg; fi) \
    && pip install --no-cache-dir \
        flatbuffers \
        cython==0.29.32 \
        # Necessary for Dataset to work properly.
        numpy\>=1.20 \
        psutil \
    && (if [ "$AUTOSCALER" = "autoscaler" ]; \
        then pip --no-cache-dir install \
        "redis>=3.5.0,<4.0.0" \
        "six==1.13.0" \
        "boto3==1.26.76" \
        "pyOpenSSL==22.1.0" \
        "cryptography==38.0.1" \
        "google-api-python-client==1.7.8" \
        "google-oauth" \
        "azure-cli-core==2.40.0" \
        "azure-identity==1.10.0" \
        "azure-mgmt-compute==23.1.0" \
        "azure-mgmt-network==19.0.0" \
        "azure-mgmt-resource==20.0.0" \
        "msrestazure==0.6.4"; \
    fi;)

WORKDIR $HOME
