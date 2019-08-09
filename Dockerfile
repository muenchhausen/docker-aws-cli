FROM docker

LABEL tools="docker-image, gitlab-aws, aws, helm, helm-charts, docker, gitlab, gitlab-ci, kubectl, s3, aws-iam-authenticator, ecr, bash, envsubst, alpine, curl, python3, pip3, git"
LABEL version="3.0.0"
LABEL description="An Alpine based docker image contains a good combination of commenly used tools\
 to build, package as docker image, login and push to AWS ECR, AWS authentication and all Kuberentes staff. \
 tools included: Docker, AWS-CLI, Kubectl, Helm, Curl, Python, Envsubst, Python, Pip, Git, Bash, AWS-IAM-Auth."
LABEL maintainer="eng.ahmed.srour@gmail.com"

ENV AWS_CLI_VERSION 1.16.214
ENV AWS_IAM_AUTHENTICATOR_VERSION 1.13.7
ENV AWS_IAM_AUTHENTICATOR_DATE 2019-06-11
ENV KUBECTL_VERSION 1.12.7
ENV KUBECTL_DATE 2019-03-27
ENV HELM_VERSION 2.12.3
ENV TERRAFORM_VERSION 0.11.14

# Install required packages
RUN apk --no-cache update && \
    apk --no-cache add git curl jq make bash ca-certificates groff less gettext python3
        # additionally required by docker-compose:
        # python3-dev libffi-dev openssl-dev gcc libc-dev make

RUN python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

# Install aws-cli, docker-compose
RUN pip3 --no-cache-dir install awscli==${AWS_CLI_VERSION} 
# docker-compose

# Install aws-iam-authenticator
ADD https://amazon-eks.s3-us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/${AWS_IAM_AUTHENTICATOR_DATE}/bin/linux/amd64/aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
RUN echo "cc35059999bad461d463141132a0e81906da6c23953ccdac59629bb532c49c83  /usr/local/bin/aws-iam-authenticator" | sha256sum -c -
RUN chmod +x /usr/local/bin/aws-iam-authenticator

# Get the kubectl binary.
ADD https://amazon-eks.s3-us-west-2.amazonaws.com/${KUBECTL_VERSION}/${KUBECTL_DATE}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN echo "fbfa5c8c43a25ae6595c3060364ceb53b02cab2fa4750f840830e523531553e6  /usr/local/bin/kubectl" | sha256sum -c -
RUN chmod +x /usr/local/bin/kubectl

# Install Helm
ADD https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz helm.tgz
RUN echo "3425a1b37954dabdf2ba37d5d8a0bd24a225bb8454a06f12b115c55907809107  helm.tgz" | sha256sum -c -
RUN tar -zxvf helm.tgz && mv linux-amd64/helm /usr/local/bin/helm && rm helm.tgz
RUN helm init --client-only

# Install Terraform
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform.zip
RUN echo "9b9a4492738c69077b079e595f5b2a9ef1bc4e8fb5596610f69a6f322a8af8dd  terraform.zip" | sha256sum -c -
RUN unzip terraform.zip && mv terraform /usr/local/bin/terraform && rm terraform.zip

# Cleanup apt cache
RUN rm -rf /var/cache/apk/*

ENV LOG=file

WORKDIR /data
