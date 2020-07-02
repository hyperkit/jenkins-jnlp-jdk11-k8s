FROM jenkins/jnlp-slave:latest-jdk11

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
  && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip setuptools

RUN pip install yq

RUN usermod -a -G sudo jenkins \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'jenkins:secret' | chpasswd

RUN curl https://storage.googleapis.com/kubernetes-release/release/v1.18.5/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

ENTRYPOINT ["jenkins-agent"]
