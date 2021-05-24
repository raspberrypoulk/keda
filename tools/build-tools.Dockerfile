FROM arm64v8/ubuntu:20.10

ENV ARCH=arm64
# Install prerequisite
RUN apt-get update && \
    apt-get install -y wget curl build-essential git

# Install azure-cli
RUN apt-get install apt-transport-https lsb-release software-properties-common dirmngr -y && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | \
        tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=arm64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
        tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
        --keyserver keyserver.ubuntu.com \
        --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF && \
    apt-get update && \
    apt-get install -y azure-cli

# Install docker client
RUN curl -LO https://download.docker.com/linux/static/stable/aarch64/docker-20.10.6.tgz && \
    docker_sha256=865038730c79ab48dfed1365ee7627606405c037f46c9ae17c5ec1f487da1375 && \
    echo "$docker_sha256 docker-20.10.6.tgz" | sha256sum -c - && \
    tar xvzf docker-20.10.6.tgz && \
    mv docker/* /usr/local/bin && \
    rm -rf docker docker-20.10.6.tgz

# Install golang
RUN GO_VERSION=1.16.4 && \
    curl -LO https://golang.org/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz && \
    go_sha256=3918e6cc85e7eaaa6f859f1bdbaac772e7a825b0eb423c63d3ae68b21f84b844 && \
    echo "$go_sha256 go${GO_VERSION}.linux-${ARCH}.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xvzf go${GO_VERSION}.linux-${ARCH}.tar.gz && \
    rm -rf go${GO_VERSION}.linux-${ARCH}.tar.gz

# Install kubectl
RUN apt-get update && apt-get install -y apt-transport-https && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl

# Install node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs

# Install operator-sdk
ENV OPERATOR_RELEASE_VERSION=v1.7.2
RUN export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac) \
    && export OS=$(uname | awk '{print tolower($0)}') \
    && export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/${OPERATOR_RELEASE_VERSION}
RUN curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH} \
    && chmod +x operator-sdk_${OS}_${ARCH} \
    && mkdir -p /usr/local/bin/ \
    && cp operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk \
    && rm operator-sdk_${OS}_${ARCH}

# Install kubebuilder tools
RUN curl -L -o kubebuilder https://github.com/kubernetes-sigs/kubebuilder/releases/download/v3.0.0/kubebuilder_linux_arm64 | tar -xz -C /tmp/ && \
    mv /tmp/kubebuilder_linux_arm64 /usr/local/kubebuilder

ENV PATH=${PATH}:/usr/local/go/bin \
    GOROOT=/usr/local/go \
    GOPATH=/go

# Install FOSSA tooling
RUN curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/fossas/fossa-cli/master/install.sh | bash
