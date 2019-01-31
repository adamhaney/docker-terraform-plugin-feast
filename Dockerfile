ARG HELM_VERSION=2.12.2

FROM python:3.7.2-stretch

ENV AWS_DEFAULT_REGION=us-east-1
ENV GOPATH="$HOME/go"

RUN apt-get update && \
    apt-get install -yqq apt-transport-https curl gnupg2 && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update

RUN apt-get install -yqq unzip kubectl wget git && \
    rm -rf /var/lib/apt/lists/*

RUN curl -s -o terraform.zip https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/terraform

RUN wget --quiet https://storage.googleapis.com/kubernetes-helm/helm-v2.12.2-linux-amd64.tar.gz  && \    
    tar --gunzip --extract --file helm-v2.12.2-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN mkdir -p "~/.terraform.d/plugins"
RUN mkdir -p "$HOME/go"
RUN curl -s -O https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz
RUN tar xf go1.11.2.linux-amd64.tar.gz
RUN mv go /usr/local/go
RUN ls /usr/local/go/bin
RUN chmod +x /usr/local/go/bin/go
RUN /usr/local/go/bin/go version
RUN mkdir -p ~/.terraform.d/plugins
RUN /usr/local/go/bin/go get -u github.com/saymedia/terraform-buildkite/terraform-provider-buildkite && mv ${GOPATH}/bin/terraform-provider-buildkite ~/.terraform.d/plugins
RUN /usr/local/go/bin/go get -u github.com/plukevdh/terraform-provider-dmsnitch && mv ${GOPATH}/bin/terraform-provider-dmsnitch ~/.terraform.d/plugins
RUN /usr/local/go/bin/go get -u github.com/DeviaVir/terraform-provider-gsuite && mv ${GOPATH}/bin/terraform-provider-gsuite ~/.terraform.d/plugins
RUN /usr/local/go/bin/go get -u github.com/adamhaney/terraform-provider-slack && mv ${GOPATH}/bin/terraform-provider-slack ~/.terraform.d/plugins
RUN /usr/local/go/bin/go get -u github.com/armory-io/terraform-provider-spinnaker && mv ${GOPATH}/bin/terraform-provider-spinnaker ~/.terraform.d/plugins

# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
RUN curl -s -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x ./aws-iam-authenticator && \
    cp ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator && \
    aws-iam-authenticator help

RUN pip install awscli
RUN mkdir -p /var/kitchen/src
COPY ./src /var/kitchen/src
WORKDIR /var/kitchen/src
RUN ls /var/kitchen/src
