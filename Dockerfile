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
      libssl-dev \
      uuid-dev \
      libgpgme11-dev \
      git  && \
    apt-get purge -y --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
RUN curl -s https://get.nextflow.io | bash \
    && mv nextflow /usr/local/bin/ \
    && chmod +x /usr/local/bin/nextflow \
    && chmod +r /usr/local/bin/nextflow \
    && rm -rf /tmp/nextflow* \
    && rm -rf /tmp/*
USER $NB_USER
WORKDIR /home/$NB_USER
ENV TMPDIR=/tmp
ENV PATH=$PATH:/home/$NB_USER/miniconda3/bin/
RUN rm -f /home/$NB_USER/environment.yml && \
    rm -f /home/$NB_USER/Dockerfile
COPY environment.yaml /home/$NB_USER/environment.yaml
COPY Dockerfile /home/$NB_USER/Dockerfile
USER root
RUN chown ${NB_UID} /home/$NB_USER/environment.yaml && \
    chown ${NB_UID} /home/$NB_USER/Dockerfile
USER $NB_USER
WORKDIR /home/$NB_USER
RUN conda env update -q -n notebook-env --file /home/$NB_USER/environment.yaml && \
    conda clean -a -y && \
    rm -rf /home/$NB_USER/.cache && \
    rm -rf /tmp/* && \
    mkdir -p /home/$NB_USER/.cache && \
    find miniconda3/ -type f -name *.pyc -exec rm -f {} \; 
EXPOSE 8888
EXPOSE 8080
CMD [ "notebook" ]
