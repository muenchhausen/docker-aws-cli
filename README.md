[![Build Status](https://travis-ci.com/muenchhausen/docker-aws-cli.svg?branch=master)](https://travis-ci.com/muenchhausen/docker-aws-cli) [![hub](https://img.shields.io/docker/pulls/muenchhausen/docker-aws-cli.svg)](https://hub.docker.com/r/muenchhausen/docker-aws-cli/)

This repo is a fork of https://github.com/aserour/docker-aws-cli. All changes will be merged back to the initial repository if possible.

## Builder docker image 


An Alpine based docker image contains a good combination of commenly used tools to build, package as docker image, login and push to AWS ECR, AWS authentication and all Kuberentes staff.

The image is mainly used as a builder images while creating CICD pipelines.

## Tools listing

|Tool                   |Description                                                                               |
|-----------------------|------------------------------------------------------------------------------------------|
|Docker Engine          |Docker image containing docker engine to offer Docker inside Docker (DinD)                |
|docker-compose         |Docker Compose                                                                            | 
|AWS CLI                |AWS commandline tools for managing simple infrastructure tasks                            |
|Python                 |Usefull scripting language and also a common rerequisite for many other tools             |
|Pip                    |Python package manager used to install many libraries and other tools i.e. aws-cli        |
|cUrl                   |Commandline professional http(s) client tool                                              |
|Bash                   |Advanced linux shell                                                                      |
|Envsubst               |Simple tool to substitute template files with matching Environment Variables values       |
|aws-iam-authenticator  |IAM authentication utility offers a secure proxy for authenticating kubectl to K8S cluster|
|Kubectl                |Kubectl used to administrate the K8S cluster                                              |
|git                    |World's most popular version control tool                                                 |
|helm                   |Package manager for K8S clusters that simplifies complex deployments with simple Charts   |
|helm3                  |Package manager (version 3) for managing K8S cluster deployments                          |
|helm-s3 plugin         |S3 integration plugin to use S3 as a private Helm Charts repositories                     |
|terraform              |HashiCorp Terraform                                                                       |

Important tools have specific versions, see file ```Dockerfile```.

## Installation guide

Simply pull the image from official docker hub using the following command as it contains nothing more than a set of open source tools.

```sh
  docker pull muenchhausen/docker-aws-cli
```

## Even more useful in Gitlab

- Please use docker enabled gitlab runner and make sure docker engine is running in priviledged mode to enable Docker inside Docker (DinD). Learn more? https://docs.gitlab.com/runner/executors/docker.html#use-docker-in-docker-with-privileged-mode
- Use the image as your builder image to be loaded into the runner during the build step initiation and enable DinD service. To acheive this please add the following snippet to your pipeline code i.e. gitlab-ci.yaml.

```yaml
docker:
    stage: create-docker-image
    image: asorour/docker-aws-cli
    services:
        - docker:dind
    variables:
        DOCKER_DRIVER: overlay           # For better build performance

    script:
        - echo 'Your build scripts goes here and you can use all of the above toolset'
```

## Credits

Ahmed Sorour, https://github.com/aserour
