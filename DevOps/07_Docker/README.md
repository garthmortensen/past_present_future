# Containers

2019.11.16
Garth Mortensen

## Background

Think about how the shipping industry uses standardized shipping containers. Software containers do the same, but for applications. Instead of deploying a stack of applications to a laptop or server, you can deploy a container which houses the application stack. As a developer, you can build an application stack once, in a container, then put that container into any hardware. Dependencies are built into the container. You can easily install everything into one container, and deploy that wherever you want. 

The key difference between virtual machines and containers is that each vm contains an OS, whereas all containers share the same OS. This means containers are much lighter weight.

![containers](C:\Users\grm\Google Drive\aStThomas\08DevOps\Assignments\11_ex\container.png)

Containers are much simpler to deploy than a vm. They start in a fraction of a second, whereas vms can take minutes. Containers are much more granular, and allow you to run a single process. Because they are much smaller, it means much less hardware is required to run them.

## Docker

Docker is an open-source Linux-based container started around 2013. It's like an API layer that lives above existing linux utilities. Containers existed for awhile, but Docker made it easy. Linux-based container solutions were around for more than a decade, but Docker popularized them.

### How it Works

* Docker Daemon (engine) runs on a host. The Daemon builds, runs and manages containers. 

* Docker CLI is the client app. It takes user input and sends it to the daemon.

* Docker Hub Registry is a collection of public images, on for instance Docker Hub.

As shown below, you provide input using the Client, which sends the commands to the daemon. The daemon uses Docker Images to create/start/stop Containers. Those images can be stored locally, and if they aren't local, they'll be pulled from the Hub Registry.

![Docker-Architecture](C:\Users\grm\Google Drive\aStThomas\08DevOps\Assignments\11_ex\Docker-Architecture.jpg)

### Docker Terms

* Host: Machine running containers.
* Image: Read only template containing files and meta-data used to create containers.
* Container: Isolated application platform containing everything needed to run an application.
* Registry: Repo of images.
* Volume: Data storage outside the container.
* Dockerfile: Script for creating images.

## Practice

### Launch CloudFormation Stack

I'm launching a Docker server running on an EC2 image, by loading the following docker-single-server.json template.

```json
{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Resources": {
        "dockerVpc": {
            "Type": "AWS::EC2::VPC",
            "Properties": {
                "EnableDnsSupport": "true",
                "EnableDnsHostnames": "true",
                "CidrBlock": "10.0.0.0/16",
                "Tags": [
                    {
                        "Key": "Project",
                        "Value": "Docker"
                    }
                ]
            }
        },
        "publicSubnet": {
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "dockerVpc"
                },
                "CidrBlock": "10.0.0.0/24"
            }
        },
        "docker1": {
            "Type": "AWS::EC2::Instance",
            "Properties": {
                "InstanceType": "t2.micro",
                "ImageId": "ami-043218c94b0cb8d43",
                "KeyName": {
                    "Ref": "KeyName"
                },
                "NetworkInterfaces": [
                    {
                        "GroupSet": [
                            {
                                "Ref": "DockerSecurityGroup"
                            }
                        ],
                        "AssociatePublicIpAddress": "true",
                        "DeviceIndex": "0",
                        "DeleteOnTermination": "true",
                        "SubnetId": {
                            "Ref": "publicSubnet"
                        }
                    }
                ],
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "docker1"
                    }
                ]
            },
            "DependsOn": [
                "PublicRoute"
            ]
        },
        "DockerSecurityGroup": {
            "Type": "AWS::EC2::SecurityGroup",
            "Properties": {
                "VpcId": {
                    "Ref": "dockerVpc"
                },
                "GroupDescription": "Allow access from HTTP and SSH traffic",
                "SecurityGroupIngress": [
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "8080",
                        "ToPort": "8080",
                        "CidrIp": "0.0.0.0/0"
                    },
                    {
                        "IpProtocol": "tcp",
                        "FromPort": "22",
                        "ToPort": "22",
                        "CidrIp": {"Ref": "YourIp"}
                    }
                ]
            }
        },
        "DockerSecurityGroupIngress": {
            "Type": "AWS::EC2::SecurityGroupIngress",
            "Properties" : {
              "IpProtocol": "-1",
              "FromPort": "-1",
              "ToPort": "-1",
              "SourceSecurityGroupId": { "Ref": "DockerSecurityGroup" },
              "GroupId": { "Fn::GetAtt": ["DockerSecurityGroup", "GroupId"]}
            }
        },
        "InternetGateway": {
            "Type": "AWS::EC2::InternetGateway",
            "Properties": {}
        },
        "VPCGatewayAttachment": {
            "Type": "AWS::EC2::VPCGatewayAttachment",
            "Properties": {
                "InternetGatewayId": {
                    "Ref": "InternetGateway"
                },
                "VpcId": {
                    "Ref": "dockerVpc"
                }
            }
        },
        "PublicRouteTable": {
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "dockerVpc"
                }
            }
        },
        "PublicRoute": {
            "Type": "AWS::EC2::Route",
            "Properties": {
                "DestinationCidrBlock": "0.0.0.0/0",
                "RouteTableId": {
                    "Ref": "PublicRouteTable"
                },
                "GatewayId": {
                    "Ref": "InternetGateway"
                }
            },
            "DependsOn": [
                "InternetGateway"
            ]
        },
        "SubnetAssociation": {
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "RouteTableId": {
                    "Ref": "PublicRouteTable"
                },
                "SubnetId": {
                    "Ref": "publicSubnet"
                }
            }
        }
    },
    "Parameters": {
      "KeyName": {
          "Description": "Name of your EC2 KeyPair to enable SSH access to the instances.",
          "Type": "AWS::EC2::KeyPair::KeyName",
          "ConstraintDescription": "must be the name of an existing EC2 KeyPair."
      },
      "YourIp": {
        "Description": "The current CIDR IP address of your workstation (x.x.x.x/32). http://checkip.amazonaws.com/",
        "Type": "String",
        "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-9]|3[0-2]))$",
        "ConstraintDescription": "Must be a valid IP CIDR range of the form x.x.x.x/x."
      }
    },
    "Outputs": {
        "manager1PublicIp": {
          "Value": {"Fn::GetAtt": ["docker1","PublicIp"]},
          "Description": "docker1 public IP"
        }
    }
}
```

This template is fed to AWS CloudFormation to create a new stack. I shell in, logging in as ubuntu user.

```bash
ssh -i "DevOps_Key.pem" ubuntu@ec2-34-203-28-217.compute-1.amazonaws.com
```

### Hello World

After shelling in, ensure Docker is already installed and ready.

```bash
docker --version
> Docker version 18.09.0, build 4d60db4
```

Run Hello World for docker

```bash
docker run busybox echo hello world
> Unable to find image 'busybox:latest' locally
> latest: Pulling from library/busybox
> 0f8c40e1270f: Pull complete
> Digest: sha256:1303dbf110c57f3edf68d9f5a16c082ec06c4cf7604831669faf2c712260b5a0
> Status: Downloaded newer image for busybox:latest
> hello world
```

Docker created a small container using the busybox image, executed a single small process, and echoed the text. That was an interactive process. Once the process is done, it stops running. This is because containers are more like supercharged processes, than vms.

Confirm the process isn't running anymore:

```bash
docker ps
CONTAINERID IMAGE COMMAND CREATED STATUS PORTS NAMES
```

Empty. Looks good. Run the ubuntu container and execute bash (we want a command shell in the container). Also run it as a virtual terminal connection:

```bash
docker run -it ubuntu bash
```

-it = interactive virtual terminal connection. In a sense, log into the container.

Docker first looks to see if ubuntu was on the local host. Because it wasn't, it pulls the image from Hub Registry, and loads it.

Because the bash command ran, we can see the command line prompt has changed to _root@bd6cf81f8132:/#_

Now, we're interactively logged into the container. Any commands we type in runs within the container, not the host shell.

```bash
root@bd6cf81f8132:/# ls /
> bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

We can see the ubuntu root directory.

```bash
exit
ubuntu@ip-10-0-0-198:~$
```

You can now see we're out of it. Now, relaunch it.

```bash
docker run -it ubuntu bash
root@6ddf1bd1385e:/# exit
```

That loaded much faster because ubuntu is already in cache.

Exit and launch a container that runs in the background, named _web1_

```bash
docker run -d -P --name web1 nginx
```

This downloads and creates a container running nginx. You should see this container running on the system,

```bash
ubuntu@ip-10-0-0-198:~$ docker ps
CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
610ba31c15c6 nginx "nginx -g 'daemon of…" 4 minutes ago Up 4 minutes 0.0.0.0:32768->80/tcp web1
```

The port mapping 0.0.0.0:32768→80/tcp web1 shows that the nginx container image exposes port 80 to its dockerfile. When you launch a container using the **-P** flag, Docker assigns a random port number (32768), and maps it to the container's exposed port 80. Docker containers usually have their own network stack, so the container networking environment is separate from the host.

Check nginx' test page with the following:

```bash
curl localhost:32768
```

This outputs some html content. Looks good? I'll stop this container and move on.

```bash
docker stop 610ba31c15c6
```

Where that last string is the container's <id>. Alternatively, use the first 4 digits of the ID

```bash
docker stop 610b
```

### Create an HTML file

I'll create some directories and a file in ubuntu's home directory.

```bash
cd ~
mkdir docker
cd docker
mkdir html
cd html
touch index.html
nano index.html
```

index.html contains the following html:

```html
<html>
<body>
	<h1>Dynacorp Industries Website</h1>
</body>
</html>
```

### Dockerfiles 

Dockerfiles are a handy way to encapsulate all the configuration commands required to build a single container. Building Docker images by hand is tedious and error-prone. A **Dockerfile provides a recipe to build images using code** in a text file. Here, I'll create a Dockerfile which builds a simple nginx webserver.

#### Create Dockerfile

Dockerfile is for **building customized docker images**. I'll create a dockerfile to meet the following requirements:

- [x] Image must be based off the nginx image
- [x] Set the image's maintainer to my name and email address
- [x] Image should expose port 80
- [x] Copy files form /html directory to /usr/share/nginx/html directory in the container - [SO](https://stackoverflow.com/questions/34871342/dockerfile-copy-folder-inside-folder) post.

Each image that you have on your system has a tag. Think of the tag as being the version of the image. The default tag is _latest_, but that's not really informative. 

```dockerfile
# Dockerfile
FROM nginx
LABEL maintainer=“garth@theinternet.com”
EXPOSE 80/tcp
COPY /html /usr/share/nginx/html
```

FROM must be the first instruction after comments. It specifies base image. Create a file and paste the above into it.

Note: You want to name the dockerfile Dockerfile, as it's the default, and simplifies the build string.


```bash
cd ~/docker
touch Dockerfile
nano Dockerfile
```

With the Dockerfile complete, you can now **build the image** from that file. Create a new Docker image called _dynacorpweb_ with tag of _1.0_. Using [this](https://stackoverflow.com/questions/28996907/docker-build-requires-1-argument-see-docker-build-help) advice, I use the following command.

```bash
docker build -t dynacorpweb:1.0 .
```

my_image:my_tag, and -t = some tag. If a tag isn’t specified then the :latest tag is used. And that is it! The dot means the dockerfile is in the current working directory.

If you named your dockerfile something else, use the following:

```bash
docker build -t dynacorpweb:1.0 --file <filename> .
```

You can list all images that are locally stored with the Docker image with:

```bash
docker images ls
```

List the running containers. Add --all to include stopped containers:

```bash
docker container ls
```

#### Launch Container

With a Docker image you can **launch a container using that image**. Launch a new container with the following configuration settings

- [x] The name of the container should be dynacorpweb1 = --name <name>:
- [x] The container should run in a detached (daemon) mode = -d
- [x] The container should map port 80 within the container to port 80 on the host server = –p 80:80
- [x] The container should have an environment variable mapping the key DYNAWEB_DB to the
  value dynadb 

Here is an example:

Run a container from the Alpine version 3.9 image, name the running container “web” and expose port 5000 externally, mapped to port 80 inside the container.

```bash
docker container run --name web -p 5000:80 alpine:3.9
```

Here is my version, to launch this **single container**:

```bash
docker container run --name dynacorpweb1 -p 80:80 --env DYNAWEB_DB=dynadb -d dynacorpweb:1.0
```
See if the docker image was built.

```bash
docker ps
```

If you need to remove a container, use:

```bash
docker container ls -a
docker stop <first 4 digits of container ID> (might be needed)
docker rm <first 4 digits of container ID>
```

--name =  Assign a name to the container
--detach , -d =  Run container in background and print container ID 
--publish , -p = Publish a container’s port(s) to the host
--env DYNAWEB_DB=dynadb

Test that the setup works.

```bash
curl localhost
```

```html
<html>
	<body>
        <h1>Dynacorp Industries Website</h1>
	</body>
</html>
```

If it worked.

View all images and containers:

```bash
docker image ls
docker container ls
```

remove an image and container:

```bash
docker image rm <first 4 digits of ID>
docker container rm <first 4 digits of ID>
```

### Docker Compose

In a production environment, you don’t want to launch individual Docker containers manually. Better, use Docker Compose to run containers. I've been told that, today, more people use k8s instead of Docker Compose to launch multiple containers. Either way, Docker Compose uses .yml to describe the settings for 1+ containers. 

Create a Docker compose file called docker-compose.yaml to launch the dynaweb1 container. Use documentation:
https://docs.docker.com/compose/

Create the file:

```bash
touch docker-compose.yml
```

Feed it.

```yaml
version: '2'
services:
  dynaweb1:
    build: .
    ports:
      - "80:80"
```

Where:

version is a template format, like in AWS Cloudformation.

The first services element is not a keyword, but just a variable name. It will be appended to the docker image name.

Services: Docker compose let's you play with multiple services, such as using Docker Swarm(?). The services may consist of a webserver, database server, etc. You can give an image for each one, set the port mappings, etc. Build is '.', telling where the Dockerfile is (meaning the current directory). Compose will run this image.

Use the following command to **launch all of the container services defined in the file**:

```bash
docker-compose up -d
```

-d = detached mode.

Check to see what was created:

```bash
docker container ls -a
```

Do you see the new container in the list? Good.

Test it one last time with:

```bash
curl localhost
```

Display the html skeleton? Great. Close it.

```bash
docker stop <id>
```


### Push Image to AWS ECR

After building a Docker image, you can store it in a repository, which allows many systems and teams to share the same image. AWS' Docker repo is **Elastic Container Registry** (ECR). 

I'll create a CloudFormation template to build a **new repo in ECR called dynacorpweb**. I'll launch the stack. Then, I'll push the image I created earlier into the new repo.

What this means is I create the following Cloudformation.json. It consists of only a repo and a few parameters.

[Syntax](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecr-repository.html) for including AWS::ECR::Repository in a CloudFormation template.

[Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/RepositoryPolicyExamples.html) on how to allow all users (principal = *) to push and pull. Also include additional Actions found in the other snippets.

Mush them together into the following:

```json
{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Resources": {
		"MyRepository": {
			  "Type": "AWS::ECR::Repository",
			  "Properties": {
				"RepositoryName" : "dynacorpweb",
				"RepositoryPolicyText" : {
				  "Version": "2008-10-17",
				  "Statement": [
					{
					  "Sid": "AllowPushPull",
					  "Effect": "Allow",
					  "Principal": "*",
					  "Action": [
						"ecr:GetAuthorizationToken",
						"ecr:BatchCheckLayerAvailability",
						"ecr:GetDownloadUrlForLayer",
						"ecr:GetRepositoryPolicy",
						"ecr:DescribeRepositories",
						"ecr:ListImages",
						"ecr:DescribeImages",
						"ecr:BatchGetImage",
						"ecr:InitiateLayerUpload",
						"ecr:UploadLayerPart",
						"ecr:CompleteLayerUpload",
						"ecr:PutImage"
						]
					}
				]
				}
			}
		}
    },
    "Parameters": {
      "KeyName": {
          "Description": "Name of your EC2 KeyPair to enable SSH access to the instances.",
          "Type": "AWS::EC2::KeyPair::KeyName",
          "ConstraintDescription": "must be the name of an existing EC2 KeyPair."
      },
      "YourIp": {
        "Description": "The current CIDR IP address of your workstation (x.x.x.x/32). http://checkip.amazonaws.com/",
        "Type": "String",
        "AllowedPattern": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(1[6-9]|2[0-9]|3[0-2]))$",
        "ConstraintDescription": "Must be a valid IP CIDR range of the form x.x.x.x/x."
      }
    }
}
```

After creation, you can find it under Chrome > AWS > ECR > Repos. Mine is:

_666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb_

**Reference**: Under Chrome > AWS > ECR > Repos, click **View Push Commands**, for all related commands.

Next, identify the image ID for the image you'd like to upload, then tag the image you'd like to upload, as:

```bash
docker image ls
...
docker tag b8e73f2d1cb2 666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb
```

Where _b8e73f2d1cb2_ is the <id> and _666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb_ is the repo name.

Now, push.

```bash
docker push 666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb

no basic auth credentials
```

Not sure what to do here. When I run:

```bash
(aws ecr get-login --no-include-email --region us-east-1)

An error occurred (AccessDeniedException) when calling the GetAuthorizationToken operation: User: arn:aws:iam::666840684413:user/DevOpsUserGarth is not authorized to perform: ecr:GetAuthorizationToken on resource: *
```

I tried running 

```bash
aws configure
```

And feeding it the security information from my .pem credentials file, but to no avail.

I've also relaxed the .json 'Statement' section to allow for more operations, but to no avail.



























## Other Content

### Other Docker Factoids

```bash
docker ps -a
```
All historical containers

```bash
docker exec -it <id> bash
```
Connect to existing container

Docker attach enters the command line of the docker. Then when you exit, you close the process. When you exec, you create a new process, and exit won't terminate it. If you want to close the container.

```bash
docker stop <id>
```

To see what changes you've made to the container, vs the base image:

```bash
docker diff
```
This might require <id>.

A = add
C = changes

To push these changes to the repo image:

```bash
docker commit <id>
```

To add a tag, which you could have done in the line above:

```bash
docker tag <id> RepoName:Tag
```

To see the layers of the docker image:

```bash
docker history <name>:<tag>
```

This shows how the docker image is constructed of multiple layers, built on top of each other.

In a dockerfile, you can additionally add lines such as:

```dockerfile
RUN apt-get update -y
```

Or else, use default commands this way:

```dockerfile
CMD figlet -f script warez
```

Where -f is font = script. CMD is a default command, but if you provide any other command, it will be overwritten:

```bash
docker run figlet:6.0 echo hello world
```

Again, this prints hello world to screen, instead of the default printout of 'warez'.

To inspect the contents of a container:

```bash
docker inspect <id>
```

This returns a json image, just like ansible setup(?) returns a json of the system configuration. If you want to display a specific key, pipe it:

```bash
docker inspect <id> | less
```

Or else, dig in programmatically:

```bash
docker inspect --format '{{.NetworkSettings.IPAddress}}' <id>
```

This returns the value from the json key defined in the variable.

Note that the double braces are just like variables in Ansible.

### Docker Order of Ops

You build a docker from an image:

```bash
docker build <name>
```

You run the docker:

```bash
docker run figlet:7.0 awesome
```

## History

```bash
    1  23/11/19 18:15:33 docker -v
    2  23/11/19 18:15:33 docker run busybox echo hello world
    3  23/11/19 18:15:33 docker ps
    4  23/11/19 18:15:33 docker run -it ubuntu bash
    5  23/11/19 18:15:33 docker run -d -P --name web1 nginx
    6  23/11/19 18:15:33 docker ps
    7  23/11/19 18:15:33 curl localhost:32768
    8  23/11/19 18:15:33 docker stop 610b
    9  23/11/19 18:15:33 cd ~
   10  23/11/19 18:15:33 mkdir docker
   11  23/11/19 18:15:33 cd docker
   12  23/11/19 18:15:33 mkdir html
   13  23/11/19 18:15:33 cd html
   14  23/11/19 18:15:33 touch index.html
   15  23/11/19 18:15:33 nano index.html
   16  23/11/19 18:15:33 cat index.html
   17  23/11/19 18:15:33 ls -la
   18  23/11/19 18:15:33 cd ../
   19  23/11/19 18:15:33 ls -la
   20  23/11/19 18:15:33 pwd
   21  23/11/19 18:15:33 dockerfile
   22  23/11/19 18:15:33 touch Dockerfile
   23  23/11/19 18:15:33 nano Dockerfile
   24  23/11/19 18:15:33 docker images
   25  23/11/19 18:15:33 docker build –-tag dynacorpweb:Dockerfile .
   26  23/11/19 18:15:33 docker build –-tag dynacorpweb .
   27  23/11/19 18:15:33 docker build –-tag dynacorpweb
   28  23/11/19 18:15:33 docker build –t dynacorpweb
   29  23/11/19 18:15:33 docker build –t dynacorpweb .
   30  23/11/19 18:15:33 docker build –t dynacorpweb /
   31  23/11/19 18:15:33 ls
   32  23/11/19 18:15:33 docker build –t dynacorpweb:Dockerfile /
   33  23/11/19 18:15:33 docker build –t dynacorpweb:Dockerfile .
   34  23/11/19 18:15:33 docker build –t
   35  23/11/19 18:15:33 docker build –t Dockerfile
   36  23/11/19 18:15:33 docker build –t dynacorpweb
   37  23/11/19 18:15:33 pwd
   38  23/11/19 18:15:33 -ls -la
   39  23/11/19 18:15:33 pwd
   40  23/11/19 18:15:33 ls
   41  23/11/19 18:15:33 cd html/
   42  23/11/19 18:15:33 ls
   43  23/11/19 18:15:33 cd ../
   44  23/11/19 18:15:33 ls
   45  23/11/19 18:15:33 nano dynacorpweb
   46  23/11/19 18:15:33 docker build -t dynacorpweb
   47  23/11/19 18:15:33 exit
   48  23/11/19 18:15:33 ls
   49  23/11/19 18:15:33 cd docker/
   50  23/11/19 18:15:33 ls
   51  23/11/19 18:15:33 ls -la
   52  23/11/19 18:15:33 cat dynacorpweb
   53  23/11/19 18:15:33 nano dynacorpweb
   54  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 ./dynacorpweb
   55  23/11/19 18:15:33 mv dynacorpweb dockercustom
   56  23/11/19 18:15:33 ls -la
   57  23/11/19 18:15:33 docker build -t dockercustom
   58  23/11/19 18:15:33 docker build -t dynacorpweb
   59  23/11/19 18:15:33 docker build -t dockercustom:1.0
   60  23/11/19 18:15:33 docker build -t dockercustom:1.0 ./dynacorpweb
   61  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 ./dockercustom
   62  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 .
   63  23/11/19 18:15:33 docker build -t dynacorpweb:1.0.
   64  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 ./
   65  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 .dockercustom
   66  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 -f dockercustom
   67  23/11/19 18:15:33 mv dockercustom Dockerfile
   68  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 ./Dockerfile
   69  23/11/19 18:15:33 pwd
   70  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 -f Dockerfile
   71  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 ./Dockerfile
   72  23/11/19 18:15:33 cd ../~
   73  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 ./Dockerfile
   74  23/11/19 18:15:33 docker build -t dynacorpweb:1.0
   75  23/11/19 18:15:33 ls
   76  23/11/19 18:15:33 cd docker/
   77  23/11/19 18:15:33 docker build -t dynacorpweb:1.0
   78  23/11/19 18:15:33 --help
   79  23/11/19 18:15:33 docker build --help
   80  23/11/19 18:15:33 docker build -t dynacorpweb:1.0
   81  23/11/19 18:15:33 sudo docker build -t dynacorpweb:1.0
   82  23/11/19 18:15:33 sudo docker build -t dynacorpweb:1.0 .
   83  23/11/19 18:15:33 nano Dockerfile
   84  23/11/19 18:15:33 sudo docker build -t dynacorpweb:1.0 .
   85  23/11/19 18:15:33 nano Dockerfile
   86  23/11/19 18:15:33 sudo docker build -t dynacorpweb:1.0 .
   87  23/11/19 18:15:33 nano Dockerfile
   88  23/11/19 18:15:33 sudo docker build -t dynacorpweb:1.0 .
   89  23/11/19 18:15:33 ls -la
   90  23/11/19 18:15:33 pwd
   91  23/11/19 18:15:33 cd html/
   92  23/11/19 18:15:33 ls -la
   93  23/11/19 18:15:33 pwd
   94  23/11/19 18:15:33 cd ../
   95  23/11/19 18:15:33 nano Dockerfile
   96  23/11/19 18:15:33 sudo docker build -t dynacorpweb:1.0 .
   97  23/11/19 18:15:33 nano Dockerfile
   98  23/11/19 18:15:33 sudo docker build -t dynacorpweb:1.0 .
   99  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 .
  100  23/11/19 18:15:33 nano Dockerfile
  101  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 .
  102  23/11/19 18:15:33 docker ps
  103  23/11/19 18:15:33 ls
  104  23/11/19 18:15:33 nano Dockerfile
  105  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 .
  106  23/11/19 18:15:33 nano Dockerfile
  107  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 .
  108  23/11/19 18:15:33 nano Dockerfile
  109  23/11/19 18:15:33 pwd
  110  23/11/19 18:15:33 nano Dockerfile
  111  23/11/19 18:15:33 docker build -t dynacorpweb:1.0 .
  112  23/11/19 18:15:33 nano Dockerfile
  113  23/11/19 18:15:33 ls -la
  114  23/11/19 18:15:33 docker images
  115  23/11/19 18:15:33 docker run --name dynacorpweb1 -d –p 80:80 dynacorpweb
  116  23/11/19 18:15:33 docker run dynacorpweb
  117  23/11/19 18:15:33 ls
  118  23/11/19 18:15:33 ls -la
  119  23/11/19 18:15:33 docker images
  120  23/11/19 18:15:33 docker run dynacorpweb:1.0
  121  23/11/19 18:15:33 pwd
  122  23/11/19 18:15:33 ls
  123  23/11/19 18:15:33 docker run --name dynacorpweb1 dynacorpweb:1.0
  124  23/11/19 18:15:33 pwd
  125  23/11/19 18:15:33 docker run --name dynacorpweb1 --env DYNAWEB_DB=dynadb dynacorpweb:1.0
  126  23/11/19 18:15:33 docker images
  127  23/11/19 18:15:33 docker
  128  23/11/19 18:15:33 pwd
  129  23/11/19 18:15:33 docker ps
  130  23/11/19 18:15:33 docker run --name dynacorpweb1 --env DYNAWEB_DB=dynadb dynacorpweb:1.0
  131  23/11/19 18:15:33 docker container ls -a
  132  23/11/19 18:15:33 docker rm 84b3
  133  23/11/19 18:15:33 docker rm 257d
  134  23/11/19 18:15:33 docker rm 84b3
  135  23/11/19 18:15:33 docker container ls -a
  136  23/11/19 18:15:33 docker run --name dynacorpweb1 --env DYNAWEB_DB=dynadb -d dynacorpweb:1.0
  137  23/11/19 18:15:33 exit
  138  23/11/19 18:15:33 hist
  139  23/11/19 18:15:33 sudo apt install hist
  140  23/11/19 18:15:33 hist
  141  23/11/19 18:15:33 pwd
  142  23/11/19 18:15:33 ls -la
  143  23/11/19 18:15:33 cd docker/
  144  23/11/19 18:15:33 ls -la
  145  23/11/19 18:15:33 docker run --name dynacorpweb1 --env DYNAWEB_DB=dynadb -d -p 80:80 dynacorpweb:1.0
  146  23/11/19 18:15:33 docker ls
  147  23/11/19 18:15:33 docker ls -a
  148  23/11/19 18:15:33 docker la -a
  149  23/11/19 18:15:33 docker ls
  150  23/11/19 18:15:33 docker container ls -a
  151  23/11/19 18:15:33 docker rm aa12
  152  23/11/19 18:15:33 docker stop aa12
  153  23/11/19 18:15:33 docker run --name dynacorpweb1 --env DYNAWEB_DB=dynadb -d -p 80:80 dynacorpweb:1.0
  154  23/11/19 18:15:33 docker container ls -a
  155  23/11/19 18:15:33 docker rm aa12
  156  23/11/19 18:15:33 docker container ls -a
  157  23/11/19 18:15:33 docker run --name dynacorpweb1 --env DYNAWEB_DB=dynadb -d -p 80:80 dynacorpweb:1.0
  158  23/11/19 18:15:33 cir; ;pca;jpst
  159  23/11/19 18:15:33 curl localhost
  160  23/11/19 18:15:33 ls
  161  23/11/19 18:15:33 pwd
  162  23/11/19 18:15:33 touch docker-compose.yml
  163  23/11/19 18:15:33 nano docker-compose.yml
  164  23/11/19 18:15:33 docker compose up
  165  23/11/19 18:15:33 docker-compose up
  166  23/11/19 18:15:33 docker container -ls
  167  23/11/19 18:15:33 docker containers -ls
  168  23/11/19 18:15:33 docker containers -ls -a
  169  23/11/19 18:15:33 docker containers ls
  170  23/11/19 18:15:33 docker container ls -a
  171  23/11/19 18:15:33 docker rm a136
  172  23/11/19 18:15:33 docker stop a136
  173  23/11/19 18:15:33 docker container ls -a
  174  23/11/19 18:15:33 docker rm a136
  175  23/11/19 18:15:33 docker container ls -a
  176  23/11/19 18:15:33 docker-compose up -d
  177  23/11/19 18:15:33 docker-compose up
  178  23/11/19 18:15:33 docker container ls -a
  179  23/11/19 18:15:33 exit
  180  23/11/19 13:25:45 ls
  181  23/11/19 13:25:47 cd docker/
  182  23/11/19 13:25:48 ls
  183  23/11/19 13:26:53 nano Dockerfile
  184  23/11/19 13:27:35 touch demo.txt
  185  23/11/19 13:27:39 vim demo.txt
  186  23/11/19 13:43:58 docker images
  187  23/11/19 13:49:22 vim Dockerfile
  188  23/11/19 13:52:47 docker container ls -a
  189  23/11/19 13:52:52 docker container
  190  23/11/19 13:52:59 docker container -a
  191  23/11/19 13:53:03 docker container ls -a
  192  23/11/19 13:53:45 curl localhost
  193  23/11/19 13:55:46 docker-compose up -d
  194  23/11/19 13:58:49 vim Dockerfile
  195  23/11/19 13:58:57 ls
  196  23/11/19 13:59:08 vim docker-compose.yml
  197  23/11/19 14:06:54 docker-compose up -d
  198  23/11/19 14:07:16 docker images
  199  23/11/19 14:07:41 docker stop b8e7
  200  23/11/19 14:07:52 docker images -ls
  201  23/11/19 14:08:16 docker container ls -a
  202  23/11/19 14:09:08 vim docker-compose.yml
  203  23/11/19 14:12:12 curl localhost
  204  23/11/19 14:13:01 docker stop 1e90
  205  23/11/19 14:13:07 docker container ls -a
  206  23/11/19 14:13:14 docker container ls
  207  23/11/19 14:13:19 docker container ls -l
  208  23/11/19 14:13:40 docker stop 1e90
  209  23/11/19 14:13:44 docker container ls -l
  210  23/11/19 14:14:12 docker image ls
  211  23/11/19 14:27:02 docker run --name dynacorpweb1 --env DYNAWEB_DB=dynadb -d –p 80:80 dynacorpweb:1.0
  212  23/11/19 14:27:17 ls -la
  213  23/11/19 14:27:59 docker build -t dynacorpweb:1.0 .
  214  23/11/19 14:28:09 docker container -ls
  215  23/11/19 14:28:12 docker container
  216  23/11/19 14:28:17 docker images ls
  217  23/11/19 14:28:30 curl localhost
  218  23/11/19 14:29:01 docker images
  219  23/11/19 14:29:35 docker build -t dynacorpweb:1.0 .
  220  23/11/19 14:29:38 docker images
  221  23/11/19 14:29:48 docker container
  222  23/11/19 14:29:49 docker containers
  223  23/11/19 14:29:54 docker container ls
  224  23/11/19 14:30:09 docker images
  225  23/11/19 14:30:50 docker container run docker_dynaweb1
  226  23/11/19 14:33:45 docker --version
  227  23/11/19 14:33:49 docker images
  228  23/11/19 14:33:53 docker container ls
  229  23/11/19 14:34:12 docker ps
  230  23/11/19 14:42:06 docker images ls
  231  23/11/19 14:42:10 docker images
  232  23/11/19 14:43:34 docker container ls -a
  233  23/11/19 14:43:40 docker container ls
  234  23/11/19 14:44:01 docker images ls
  235  23/11/19 14:44:10 docker images ls -a
  236  23/11/19 14:44:20 docker image ls
  237  23/11/19 14:45:40 docker image ls -a
  238  23/11/19 14:45:45 docker container ls -a
  239  23/11/19 14:45:52 docker image ls
  240  23/11/19 14:45:55 docker image ls -a
  241  23/11/19 14:46:31 docker image rm b8e7
  242  23/11/19 14:47:13 docker-compose up -d
  243  23/11/19 14:47:23 docker image ls
  244  23/11/19 14:47:27 docker container ls
  245  23/11/19 14:47:36 curl localhost
  246  23/11/19 14:48:15 docker stop 1e90
  247  23/11/19 14:48:54 docker container ls
  248  23/11/19 14:49:03 curl localhost
  249  23/11/19 14:49:25 docker run --name dynacorpweb --env DYNAWEB_DB=dynadb -d –p 80:80 dynacorpweb:1.0
  250  23/11/19 14:49:31 docker run --name dynacorpweb1 --env DYNAWEB_DB=dynadb -d –p 80:80 dynacorpweb:1.0
  251  23/11/19 14:49:50 docker ps -a
  252  23/11/19 14:49:52 docker ps
  253  23/11/19 14:50:07 docker diff
  254  23/11/19 14:53:58 docker container
  255  23/11/19 14:54:01 docker container ls
  256  23/11/19 14:54:35 docker images ls
  257  23/11/19 14:54:38 docker images ls -a
  258  23/11/19 14:54:43 docker image ls
  259  23/11/19 14:54:52 clear
  260  23/11/19 14:54:54 docker image ls
  261  23/11/19 14:55:09 docker run --name dynacorpweb1
  262  23/11/19 14:55:50 docker container run --name dynacorpweb1 --env DYNAWEB_DB=dynadb -d –p 80:80 dynacorpweb:1.0
  263  23/11/19 15:02:01 docker container run --name dynacorpweb1 -p 80:80 dynacorpweb:1.0
  264  23/11/19 15:03:38 docker container ls
  265  23/11/19 15:06:37 docker container run --name dynacorpweb1 -p 80:80 --env DYNAWEB_DB=dynadb -d dynacorpweb:1.0
  266  23/11/19 15:06:55 docker container
  267  23/11/19 15:06:57 docker container ls
  268  23/11/19 15:14:13 docker images
  269  23/11/19 15:14:15 docker containers
  270  23/11/19 15:14:18 docker container
  271  23/11/19 15:14:21 docker container ls
  272  23/11/19 15:14:31 docker close 991e
  273  23/11/19 15:14:36 docker stop 991e
  274  23/11/19 15:14:42 docker container ls
  275  23/11/19 15:15:13 docker image -ls
  276  23/11/19 15:15:16 docker image
  277  23/11/19 15:15:18 docker imags
  278  23/11/19 15:15:20 docker images
  279  23/11/19 15:15:23 docker images -ls
  280  23/11/19 15:17:11 docker container ls
  281  23/11/19 15:47:33 HISTTIMEFORMAT="%d/%m/%y %T "
  282  23/11/19 15:47:34 history
  283  23/11/19 16:26:10 exit
  284  23/11/19 18:15:33 docker images
  285  23/11/19 18:15:33 docker push garth/dpcler_dynaweb1
  286  23/11/19 18:15:33 docker push garth/dpcler_dynaweb1:1.0
  287  23/11/19 18:15:33 docker push garth/dpcler_dynaweb1:latest
  288  23/11/19 18:15:33 docker push garth/docker_dynaweb1
  289  23/11/19 18:15:33 docker push garth/docker_dynaweb1:latest
  290  23/11/19 18:15:33 docker push docker_dynaweb1:latest
  291  23/11/19 18:15:33 docker push 666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb
  292  23/11/19 18:15:33 clear
  293  23/11/19 18:15:33 docker container list
  294  23/11/19 18:15:33 docker image list
  295  23/11/19 18:15:33 docker push 666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb
  296  23/11/19 18:15:33 docker push docker_dynaweb1 666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb
  297  23/11/19 18:15:33 docker images
  298  23/11/19 18:15:33 docker tag b8e73f2d1cb2 666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb
  299  23/11/19 18:15:33 docker push 666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb
  300  23/11/19 18:15:33 docker tag b8e73f2d1cb2 666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb
  301  23/11/19 18:15:33 docker push 666840684413.dkr.ecr.us-east-1.amazonaws.com/dynacorpweb
  302  23/11/19 18:15:33 $(aws ecr get-login --no-include-email --region us-east-1)
  303  23/11/19 18:15:33 aws configure
  304  23/11/19 18:15:33 $(aws ecr get-login --no-include-email --region us-east-1)
  305  23/11/19 18:15:33 get-login
  306  23/11/19 18:15:33 $(aws ecr get-login --no-include-email --region us-east-1)
  307  23/11/19 18:15:33 aws configure
  308  23/11/19 18:15:33 $(aws ecr get-login --no-include-email --region us-east-1)
  309  23/11/19 18:15:33 aws ecr get-login
  310  23/11/19 18:15:33 get-login
  311  23/11/19 18:15:33 docker login
  312  23/11/19 18:15:33 (aws ecr get-login --no-include-email --region us-east-1)
  313  23/11/19 18:15:33 $(aws ecr get-login --no-include-email --region us-east-1)
  314  23/11/19 18:15:33 (aws ecr get-login --no-include-email --region us-east-1)
  315  23/11/19 18:15:33 clear
  316  23/11/19 18:15:33 docker images
  317  23/11/19 18:15:33 docker containers
  318  23/11/19 18:15:33 docker container
  319  23/11/19 18:15:33 docker container list
  320  23/11/19 18:15:33 clear
  321  23/11/19 18:15:33 exit
  322  23/11/19 18:15:38 ls -l
  323  23/11/19 18:15:43 ls -la
  324  23/11/19 18:16:00 cd docker/
  325  23/11/19 18:16:01 ls -la
  326  23/11/19 18:16:08 cat demo.txt
  327  23/11/19 18:16:12 rm demo.txt
  328  23/11/19 18:16:14 clear
  329  23/11/19 18:16:16 ls -la
  330  23/11/19 18:16:25 cat html/
  331  23/11/19 18:16:30 cd html/
  332  23/11/19 18:16:32 ls -la
  333  23/11/19 18:16:36 cat index.html
  334  23/11/19 18:16:47 cd ../
  335  23/11/19 18:16:49 ls -la
  336  23/11/19 18:16:55 cat Dockerfile
  337  23/11/19 18:16:59 nano Dockerfile
  338  23/11/19 18:18:56 clear
  339  23/11/19 18:19:02 docker container ls
  340  23/11/19 18:19:12 docker image list
  341  23/11/19 18:19:14 docker image ls
  342  23/11/19 18:20:46 docker run -it ubuntu bash
  343  23/11/19 18:21:38 docker container
  344  23/11/19 18:21:40 docker container list
  345  23/11/19 18:21:43 clear
  346  23/11/19 18:22:10 docker ps
  347  23/11/19 18:22:23 curl localhost
  348* 23/11/19 18:23:42 docker run
  349  23/11/19 18:23:48 docker container ls
  350  23/11/19 18:24:05 docker image
  351  23/11/19 18:24:07 docker image ls
  352  23/11/19 18:25:37 docker container run --name dynacorpweb1 -p 80:80 --env DYNAWEB_DB=dynadb -d dynacorpweb:1.0
  353  23/11/19 18:25:40 clear
  354  23/11/19 18:25:46 docker container run --name dynacorpweb2 -p 80:80 --env DYNAWEB_DB=dynadb -d dynacorpweb:1.0
  355  23/11/19 18:25:52 docker container run --name dynacorpweb3 -p 80:80 --env DYNAWEB_DB=dynadb -d dynacorpweb:1.0
  356  23/11/19 18:26:01 docker container
  357  23/11/19 18:26:03 docker container ls
  358  23/11/19 18:26:24 localhost
  359  23/11/19 18:26:29 curl localhost
  360  23/11/19 18:26:58 docker ps
  361  23/11/19 18:27:10 docker stop c3c9
  362  23/11/19 18:27:14 docker ps
  363  23/11/19 18:27:22 docker container lisrt
  364  23/11/19 18:27:24 docker container list
  365  23/11/19 18:27:43 ls -la
  366  23/11/19 18:27:49 cat docker-compose.yml
  367  23/11/19 18:28:35 docker-compose up -d
  368  23/11/19 18:28:42 docker container list
  369  23/11/19 18:28:49 docker stop 1e90
  370  23/11/19 18:28:52 docker container list
  371  23/11/19 18:31:43 docker image ls
  372  23/11/19 18:32:50 history
  373  23/11/19 18:33:36 HISTTIMEFORMAT="%d/%m/%y %T "
  374  23/11/19 18:33:38 history
```

