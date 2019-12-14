DevOps  
Garth Mortensen  
2019.12.13  

# Overview

Create a code pipeline to build a website in Docker images and deploy the website to a production environment. 

# Steps

Create a GitHub repo for the Final, using https://classroom.github.com/a/HSxmoQkP

```sh
git clone https://github.com/UST-SEIS665/final-project-gmort01.git
```

1. Update html/index.php

- [x] Update with your name

2. Add a Dockerfile

Let’s build a simple apache+php webserver container using a Dockerfile. Create the Dockerfile in the root directory in the repo. Here are the configuration requirements for the Docker image:

- [x] The new image must be based off the php:7.2-apache image.
- [x] Set the maintainer of the image to your name and email address.
- [x] The image should expose port 80.
- [x] Copy the file from the html directory to the /var/www/html directory in the container.

``` dockerfile
# Dockerfile
FROM php:7.2-apache
LABEL maintainer=“garth”
LABEL email=“garth@theinternet.com”
EXPOSE 80/tcp
COPY /html /var/www/html
```

3. Update buildspec.yml

Build it in the build stage of a code pipeline. 

- [x] Update the yaml to create a new Docker image called phpweb with a tag of 1.0 using the Dockerfile.

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      docker: 18
    commands:
      - nohup /usr/local/bin/dockerd --host=unix:///var/run/docker.sock --host=tcp://127.0.0.1:2375 --storage-driver=overlay2&
      - timeout 15 sh -c "until docker info; do echo .; sleep 1; done"      
  pre_build:
    commands:
      - echo test CodeBuild docker runtime
      - docker info
  build:
    commands:
      - echo Build the website
      - docker build -t phpweb:1.0 .
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Saving the Docker image...
      - docker save phpweb:1.0 > finalweb.tar
      
artifacts:
  files:
    - '**/*'
  name: docker-web-$(date +%y%m%d%H%M).zip
```

Inserted: **- docker build -t phpweb:1.0 .**

You need the ending period!

4. Add a Docker Compose File

Create a basic Docker compose file called docker-compose.yaml in the repo's root directory, to launch the finalweb1 container with the following configuration settings:

- [x] Create docker-compose.yaml
- [x] The name of the service should be finalweb1.
- [x] The container should map port 80 within the container to port 80 on the host server.
- [x] Use the image phpweb with a tag of 1.0

```yaml
version: '2'
services:
  finalweb1:
	image: phpweb:1.0
    ports:
      - "80:80"
```

5. Update scripts/start_server.sh

In the deployment stage, the code pipeline will follow instructions in appspec.yml to install and configure applications. Update start_server.sh in the scripts folder.

- [ ] 

- [x] Update the docker-compose command to create all of the container services defined in the docker-compose.yaml in a detached mode.

  ```yaml
  #!/bin/bash
  if [ -z `docker-compose ps -q finalweb1` ] || [ -z `docker ps -q --no-trunc | grep $(docker-compose ps -q finalweb1)` ]; then
    echo "finalweb1 is not running."
    docker-compose up -d
  else
    echo "finalweb1 is running."
  fi
  ```

Inserted **docker-compose up -d**, where -d stands for detached.

6. Update final-docker-pipeline-template.json

- [x] Replace the AMI ID with the AMI used in docker-single-server.json. 

Replace:

> ami-026c8acd92718196b

with:

> ami-043218c94b0cb8d43

- [x] You also need to finish the projectURL in the output section. This output needs to refer GitHubUsername and GitHubRepositoryName in the parameter section.

```json
"projectURL": {
    "Description": "Git project URL. (https://github.com/GitHubUsername/GitHubRepositoryName.git)",
    "Value": {"Fn::Join": ["",
                           ["https://github.com/",
                            {"Ref":"GitHubUsername"},
                            {"Ref":"GitHubRepositoryName"},
                            ".git"
                           ]
                          ]
             }
}
```

## Create the Final Website

Create a CloudFormation stack with final-docker-pipeline-template.json.

- [x] Parameter “GitHubUsername” is UST-SEIS665

The repo should contain:

- html/
- scripts/
- html/index.php
- scripts/ 
  - should contain 3 files
- final-docker-pipeline-template.json
- Dockerfile
- docker-compose.yaml
- buildspec.yml
- appspec.yml
- README.md

## Push to Guthub

```sh
git status
git add .
git status
git commit -m "quick push"
git push
```

Finally, **Terminate Resources**

## Notes


edit the readme.md with your name

do the dockerimage

use codepipeline to run dockerimage
remember the final . at end of docker thing

6. use intrinsic function join

when launching stack, go to codepipeline, and it may still be processing request.
when cloudformation stack says its done, go to code pipeline, see if job done.
once done, go to check ELB point.

To generate github access token, 

Github top right avatar > settings > developer settings > Personal Access Tokens > Generate New Token
check Repo
check admin:repo_hook
generate
then token appears at top, and use it for the stack