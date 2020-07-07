FROM docker:19.03.11

LABEL version="4.2.0"

ENV AWS_CLI_VERSION 1.16.314
ENV AWS_IAM_AUTHENTICATOR_VERSION 1.14.6
ENV AWS_IAM_AUTHENTICATOR_DATE 2019-08-22
ENV KUBECTL_VERSION 1.14.6
ENV KUBECTL_DATE 2019-08-22
ENV HELM_VERSION 2.12.3
ENV HELM3_VERSION 3.1.2
ENV TERRAFORM_VERSION 0.12.15

# Install required packages
RUN apk --no-cache update && \
    apk --no-cache add git curl jq make bash ca-certificates groff less gettext python3 py-pip python-dev libffi-dev openssl-dev gcc libc-dev bash git openssh openssh-client

# Install docker-compose
RUN pip install docker-compose

RUN python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

# Install aws-cli
RUN pip3 --no-cache-dir install awscli==${AWS_CLI_VERSION}

# Install aws-iam-authenticator
ADD https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/${AWS_IAM_AUTHENTICATOR_DATE}/bin/linux/amd64/aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
RUN echo "cc35059999bad461d463141132a0e81906da6c23953ccdac59629bb532c49c83  /usr/local/bin/aws-iam-authenticator" | sha256sum -c -
RUN chmod +x /usr/local/bin/aws-iam-authenticator

# Get the kubectl binary.
ADD https://amazon-eks.s3-us-west-2.amazonaws.com/${KUBECTL_VERSION}/${KUBECTL_DATE}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN echo "387caa16fb715db9304bbbef444a94db5b9b1e67a75c478aefe56e9c253fc5c9  /usr/local/bin/kubectl" | sha256sum -c -
RUN chmod +x /usr/local/bin/kubectl

# Install Helm
ADD https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz helm.tgz
RUN echo "3425a1b37954dabdf2ba37d5d8a0bd24a225bb8454a06f12b115c55907809107  helm.tgz" | sha256sum -c -
RUN tar -zxvf helm.tgz && mv linux-amd64/helm /usr/local/bin/helm && rm helm.tgz
RUN helm init --client-only

# Install Helm3
ADD https://get.helm.sh/helm-v${HELM3_VERSION}-linux-amd64.tar.gz helm3.tgz
RUN echo "e6be589df85076108c33e12e60cfb85dcd82c5d756a6f6ebc8de0ee505c9fd4c  helm3.tgz" | sha256sum -c -
RUN tar -zxvf helm3.tgz && mv linux-amd64/helm /usr/local/bin/helm3 && rm helm3.tgz
RUN helm3 version --client --short

# Install Terraform
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform.zip
RUN echo "2acb99936c32f04d0779c3aba3552d6d2a1fa32ed63cbca83a84e58714f22022  terraform.zip" | sha256sum -c -
RUN unzip terraform.zip && mv terraform /usr/local/bin/terraform && rm terraform.zip

# Cleanup apt cache
RUN rm -rf /var/cache/apk/*

ENV LOG=file

WORKDIR /data
