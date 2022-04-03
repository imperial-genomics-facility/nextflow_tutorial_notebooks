FROM imperialgenomicsfacility/base-notebook-image:release-v0.0.7
LABEL maintainer="imperialgenomicsfacility"
LABEL version="0.0.1"
LABEL description="Docker image for running pipeline tutorials"
ENV NB_USER vmuser
ENV NB_UID 1000
USER root
WORKDIR /
RUN apt-get -y update &&   \
    apt-get install --no-install-recommends -y \
      build-essential \
      libseccomp-dev \
      pkg-config \
      squashfs-tools \
      cryptsetup \
      libfontconfig1 \
      libxrender1 \
      libreadline-dev \
      libreadline7 \
      libicu-dev \
      libc6-dev \
      icu-devtools \
      libjpeg-dev \
      libxext-dev \
      libcairo2 \
      libicu60 \
      gcc \
      g++ \
      make \
      libgcc-5-dev \
      gfortran \
      default-jre \
      default-jdk-headless \
      squashfs-tools \
      git  && \
    apt-get purge -y --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
RUN curl -s https://get.nextflow.io | bash \
    && mv nextflow /usr/local/bin/ \
    && chmod +x /usr/local/bin/nextflow \
    && chmod +r /usr/local/bin/nextflow \
    && rm -rf /tmp/nextflow*
RUN wget https://go.dev/dl/go1.18.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.18.linux-amd64.tar.gz && \
    rm -rf go1.18.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"
ENV SINGULARITY_VERSION=3.9.5
RUN wget https://github.com/sylabs/singularity/releases/download/v${SINGULARITY_VERSION}/singularity-ce-${SINGULARITY_VERSION}.tar.gz && \
    tar -xzf singularity-ce-${SINGULARITY_VERSION}.tar.gz && \
    cd singularity-ce-${SINGULARITY_VERSION} && \
    ./mconfig && \
    make -C builddir && \
    make -C builddir install && \
    cd .. && \
    rm -rf singularity-ce-${SINGULARITY_VERSION} singularity-ce-${SINGULARITY_VERSION}.tar.gz && \
    rm -rf /tmp/*
USER $NB_USER
WORKDIR /home/$NB_USER
ENV TMPDIR=/tmp
ENV PATH=$PATH:/home/$NB_USER/miniconda3/bin/
RUN rm -f /home/$NB_USER/environment.yml && \
    rm -f /home/$NB_USER/Dockerfile
COPY environment.yml /home/$NB_USER/environment.yml
COPY Dockerfile /home/$NB_USER/Dockerfile
USER root
RUN chown ${NB_UID} /home/$NB_USER/environment.yml && \
    chown ${NB_UID} /home/$NB_USER/Dockerfile
USER $NB_USER
WORKDIR /home/$NB_USER
RUN conda env update -q -n notebook-env --file /home/$NB_USER/environment.yml && \
    conda clean -a -y && \
    rm -rf /home/$NB_USER/.cache && \
    rm -rf /tmp/* && \
    mkdir -p /home/$NB_USER/.cache && \
    find miniconda3/ -type f -name *.pyc -exec rm -f {} \; 
EXPOSE 8888
EXPOSE 8080
CMD [ "notebook" ]
