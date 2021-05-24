#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM arm64v8/ubuntu:20.10

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ARG GO_VERSION=1.16.4
ARG ARCH=arm64

# Configure apt, install packages and tools
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get -y install git iproute2 procps lsb-release wget curl build-essential
    # Install golang
RUN curl -LO https://golang.org/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz && \
    go_sha256=8b18eb05ddda2652d69ab1b1dd1f40dd731799f43c6a58b512ad01ae5b5bba21 && \
    echo "$go_sha256 go${GO_VERSION}.linux-${ARCH}.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xvzf go${GO_VERSION}.linux-${ARCH}.tar.gz && \
    rm -rf go${GO_VERSION}.linux-${ARCH}.tar.gz
ENV GOOS=linux
ENV GOARCH=${ARCH}
ENV PATH=/usr/local/go/bin:${PATH}
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
    #
    # Install gocode-gomod
#RUN go get -x -d github.com/stamblerre/gocode 2>&1 \
#    && go build -o gocode-gomod github.com/stamblerre/gocode \
#    && mv gocode-gomod $GOPATH/bin/
#RUN go clean -modcache 2>&1
    #
    # Install Go tools
RUN go get -u -v \
        github.com/bits-and-blooms/bitset \
        github.com/mdempsky/gocode \
        github.com/uudashr/gopkgs/v2 \
        github.com/alecthomas/kingpin \
        github.com/golangci/golangci-lint \
        github.com/go-delve/delve/cmd/dlv \
         2>&1

RUN go get -u -v \
        github.com/ramya-rao-a/go-outline \
        github.com/acroca/go-symbols \
#        github.com/raspberrypoulk/godoctor \
        golang.org/x/tools/cmd/guru \
        honnef.co/go/tools/... \
        golang.org/x/tools/cmd/gorename \
        github.com/rogpeppe/godef \
        github.com/zmb3/gogetdoc \
        github.com/haya14busa/goplay/cmd/goplay \
        github.com/sqs/goreturns \
        github.com/josharian/impl \
        github.com/davidrjenni/reftools/cmd/fillstruct \
        github.com/fatih/gomodifytags \
        github.com/cweill/gotests/... \
        golang.org/x/tools/cmd/goimports \
        golang.org/x/lint/golint \
        golang.org/x/tools/gopls  \
        github.com/mgechev/revive  \
        2>&1 \
    # Install golangci-lint
    #&& curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.40.1 \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME 

    # Add coreutils for uname and awk
RUN apt-get install -y coreutils awk 2&>1
    # [Optional] Add sudo support
RUN apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME 2&>1
    # Docker install
RUN apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
    && add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli 2&>1
    #
    # Install pip & pre-commit
RUN apt-get -y install python3-pip \
    && pip install --no-cache-dir pre-commit \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Enable go modules
ENV GO111MODULE=on

ENV OPERATOR_RELEASE_VERSION=v1.7.2
#RUN export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac) \
##    export OSNAME=$(uname | awk '{print tolower($0)}') \
#    export OPERATOR_SDK_DL_URL=$('https://github.com/operator-framework/operator-sdk/releases/download/$OPERATOR_RELEASE_VERSION') \
#    echo $OPERATOR_SDK_DL_URL/operator-sdk_$OSNAME_$ARCH
RUN curl -LO https://github.com/operator-framework/operator-sdk/releases/download/v1.7.2/operator-sdk_linux_arm64 \
    && chmod +x ./operator-sdk_linux_arm64 \
    && mkdir -p /usr/local/bin/ \
    && cp ./operator-sdk_linux_arm64 /usr/local/bin/operator-sdk \
    && rm ./operator-sdk_linux_arm64
