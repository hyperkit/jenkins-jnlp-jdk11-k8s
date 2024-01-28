FROM jenkins/inbound-agent:latest-jdk11

USER root

RUN echo "deb http://deb.debian.org/debian buster main contrib\n" > /etc/apt/sources.list \
    && echo "deb http://deb.debian.org/debian-security/ buster/updates main contrib\n" >> /etc/apt/sources.list \
    && echo "deb http://deb.debian.org/debian buster-updates main contrib\n" >> /etc/apt/sources.list

RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    openssh-client ssh-askpass\
    ca-certificates \
    tar zip unzip \
    wget curl \
    git \
    build-essential \
    less nano tree \
    jq \
    python python-pip groff \
    rlwrap \
    rsync \
    maven \
    dnsutils \
    awscli \
  && rm -rf /var/lib/apt/lists/*
  
RUN curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.11/aws-iam-authenticator_0.6.11_linux_amd64 \
  && chmod +x ./aws-iam-authenticator \
  && cp ./aws-iam-authenticator /usr/bin/aws-iam-authenticator 

RUN pip install --upgrade pip setuptools

RUN pip install yq

RUN curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh

RUN usermod -a -G sudo jenkins \
  && usermod -a -G docker jenkins \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'jenkins:secret' | chpasswd

RUN mkdir -p ~/.docker/cli-plugins

RUN curl https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx

RUN curl https://dl.k8s.io/release/v1.28.3/bin/linux/amd64/kubectl -Lo /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

RUN git config --global --add safe.directory '*'

ENTRYPOINT ["jenkins-agent"]
