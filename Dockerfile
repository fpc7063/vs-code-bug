FROM debian:bookworm

LABEL maintainer="Francisco Pena <francisco.pc7063@gmail.com>"
ENV DOCKER_WORKDIR /opt/iac
ENV USER_NAME ansible
ENV USER_HOME_DIR /home/${USER_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils apt-transport-https locales bash-completion ca-certificates git \
        curl python3 python3-venv python3-pip netcat-openbsd traceroute iputils-ping iproute2 \
        man iputils-arping iputils-tracepath bash && \
    sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    rm -rf /var/lib/apt/lists/*


ENV TZ America/Sao_Paulo
ENV LANG_ALT "pt_BR.UTF-8"
ENV LANG "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"

RUN locale-gen ${LANG} && \
    dpkg-reconfigure -f noninteractive tzdata && \
    dpkg-reconfigure --frontend=noninteractive locales


WORKDIR ${DOCKER_WORKDIR}
COPY ./ansible/requirements.txt /opt/requirements.txt
RUN python3 -m venv /opt/venv
ENV PATH "/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r /opt/requirements.txt
COPY . ${DOCKER_WORKDIR}

RUN useradd ansible \
    --uid 1000 \
    --user-group \
    --shell /bin/bash \
    --home "${USER_HOME_DIR}" && \
    mkdir ${USER_HOME_DIR}
RUN mkdir ~/.ssh && \
    mv ${DOCKER_WORKDIR}/${USER_NAME}/ssh/ssh_config ${USER_HOME_DIR}/.ssh && \
    mv ${DOCKER_WORKDIR}/${USER_NAME}/ssh/ansible.pem ${USER_HOME_DIR}/.ssh

RUN chown -Rf ansible:ansible ${USER_HOME_DIR}
USER ansible

ENTRYPOINT [ "/bin/bash", "-c" ]

