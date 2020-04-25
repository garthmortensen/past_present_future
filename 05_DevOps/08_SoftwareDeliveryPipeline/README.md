# AWS Software Delivery Pipeline

2019.11.24
Garth Mortensen

_Create an automated software delivery pipeline using CodeCommit, CodeBuild, CodeDeploy and CodePipeline._

## Background

A deployment pipeline takes software from a Developer's desktop to a production environment, and with greater velocity and reliability. The software is automatically built and tested, and making changes to software is much easier because every change is tested the same way. Back in the day, you'd have a manual build, manual testing processes, manual deployment. These manual stages are prone to mistakes, and difficult to reproduce. Automation fixes this. This also means that little updates are much easier to quickly deploy into production. Every single code change goes through the same testing process. 

People who build these pipeline processes might have job titles such as CI/CD engineers, Software Delivery engineers, DevOps Engineer, Release Engineer or Build Engineer, but Devs need to know how to do this themselves now.

CI/CD pipelines are used to build software _and_ infrastructure.

### Basic Pipeline

Code is checked in and either passed or failed with feedback and fixed. It goes back and forth until you reach Release.

![Continuous delivery](https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Continuous_Delivery_process_diagram.svg/2000px-Continuous_Delivery_process_diagram.svg.png)

#### Local Dev Stage

You run and test software on local workstation, ideally in a container. You search for syntax errors, style defects using a linter application. You perform unit testing (small, modular function tests). 

Dev commits code into Git central repo triggering the Build Stage.

#### Build Stage

Build system creates build environment, cloning changes in repo. It lints, unit tests, and may compile the binary. 

The output artifacts are packaged and stored on a **artifact repo**, which contains versions. This may be a server, or an S3 bucket.  

#### Testing Stage

Output artifacts are deployed into testing environment. 

A number of automated API/GUI tests, using perhaps Selenium, are ran. 

There's almost always a few manual tests done as well. Click another button to resume automation.

#### Production Stage

Code artifact is promoted to either one last intermediate Staging Environment, or straight to Production Environment. 

Automated "smoke tests" are run against deployment to validate application working properly. These are quick, simple tests to ensure the key functionality is working properly. The automated testing suite in previous stage is the real test.

If you previously deployed to the intermediate Staging Environment, now you would deploy to Production Environment. This would give one last measure of certainty that everything is good.

### AWS Services Used

CodeCommit = a lighter version of GitHub. Free tier for teams of 5 or less.

CodeBuild = Managed continuous integration service which allows you to compile code, run unit tests, and create deployment artifacts.

The beauty of it is that AWS will provide you with everything you need to create the output artifact. You don't need any EC2s or manage build environments, etc. It also scales from teams of 1 to 100 developers. 

It provides you with prepackaged environments for things like Ruby or Java to build android applications, etc. You can also create custom ones. Billed by the minute. 100 minutes free/month. In my work, I'll likely use less than a minute.

The service starts by you defining the **build project**. In it, you point to the source code (github, s3, etc), define the build environment, and a set of build commands. Also, where to store output (generally an S3 bucket).

The **build environment** might specify the OS, programming language runtimes (python interpreter, java SDK), tools such as Maven.

The build spec is defined by buildspec.yaml file, located in your repo's root directory. 

CodeDeploy = A service which automates application code deployments to EC2s, Lambdas, dockers in ECS or a local server.

It's basically an automated way of deploying your application code. Back in the day, you'd need to log into a server, download the application code, run a series of commands to update the services running on the server. If you had 10 servers, this was slow. Manual, error-prone process. CodeDeploy can do thousands of servers automatically.

You tell CodeDeploy about your application, how it should be deployed, and where it should be deployed to. You add a special configuration file, appspec.yml, which describes how to install the software. 

* Application: code components you want to deploy.
* Compute platform: where you want to deploy application code to (EC2, Lambda, ECS…)
* Deployment group: a set of individual compute instances (EC2)
* Deployment type: the method used to make the latest application version available.

CodePipeline = This integrates together many of the other AWS service delivery components. It is a fully managed continuous delivery service to: 

* Check in code to source control.
* Build software artifacts.
* Automatically deploy artifacts to compute
  environment

It does this by integrating CodeCommit/GitHub, CodeBuild, and CodeDeploy. It has a pipeline architecture that consist of a set of sequentially executed stages, with each stage having a set of actions. For example:

1. Source: Retrieve source code from repository (CodeCommit, GitHub, S3).
2. Test: Run unit tests (CodeBuild, CloudBees, Jenkins, TeamCity)
3. Build: Compile and/or package source code into output artifact (CodeDeploy, Device Farm, Jenkins, Runscop).
4. Deploy: Install artifact in compute environment (S3, CloudFormation, CodeDeploy).

## Begin

### Create a CloudFormation Template

Starting with [this](https://seis665.s3.amazonaws.com/app-codebuild-template.json) template, build a CloudFormation template to create all of the resources for
this project. It should include an S3 bucket, CodeCommit repo, CodeBuild project, and
a CodePipeline pipeline.

#### Create a CodeCommit Repo

Start by adding a [CodeCommit](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codecommit-repository.html) ([link 2](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codecommit-repository-code.html), [link 3](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codecommit-repository-s3.html) )repo to the CloudFormation template. This repo will be used to host some Java source code. 

- [x] Name = java-project

- [x] CloudFormation should automatically copy a .zip archive from an S3 bucket and extract to the repo. This technique can be used to bootstrap the repo files.

- [x] The **Code property** will reference a source bucket. The value of this property is the actual bucket name, not a URL

- [x] Upload [this](https://seis665.s3.amazonaws.com/java-project.zip) .zip file to an S3 bucket.

  

```json
"JavaRepo" : {
    "Type" : "AWS::CodeCommit::Repository",
    "Properties" : {
        "Code" : {
            "S3" : {
                "Bucket" : "20191128devopsjavabucket",
                "Key" : "java-project.zip"
            }
        },
        "RepositoryDescription" : "CodeCommit repo for exploration",
        "RepositoryName" : "java-project"
    }
}
```

#### Modify the CodeBuild Project

My current CloudFormation template was written for Github. I'll edit it to work with CodeBuild. 

- [x] Since this no longer uses GitHub there’s no reason to pass a projectUrl parameter into the template. We can pass the CodeCommit repository information to the CodeBuild project because both resources are defined in the same template.
- [x] The [Source property](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codebuild-project.html#cfn-codebuild-project-source) ([link 2](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-source.html), [link 3](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-source.html#cfn-codebuild-project-source-type)) in the CodeBuild project tells the CodeBuild service where to find the application source code.
- [x] The location of the CodeCommit repository is going to reference the CloneUrlHttp attribute.
- [x] The ReportBuildStatus property is not supported by CodeBuild projects using CodeCommit repositories and can be removed.
- [x] CodeCommit doesn’t use webhooks to trigger CodeBuild projects.
- [x] The CodePipeline project resource uses a custom IAM role (AppBuildRole) to access other AWS services and resources. For example, the role allows the project to retrieve and store objects in an S3 artifact bucket. The role does not currently allow CodePipeline to pull source code from a CodeCommit repository. Update the project role to allow this. **Added this to line 166**

Now I upload this CloudFormation.json template and test it out by:

- [x] Visiting the CodeCommit web console. Check for the existence of file "buildspec.yml". 

- [x] Go to CodeBuild and verify that a build project exists, using the repo I created.
- [x] Start a build to test the process. Take a look at the build logs as the project is building.

#### Add a pipeline resource

So far, the stack has built a CodeBuild project, which retrieved source code from CodeCommit, built it, and generated an output artifact in S3. We can combine a number of build processes together by creating a pipeline. Through AWS, the service is called CodePipeline, and we add it to the CloudFormation template. 

I'll use [this](https://seis665.s3.amazonaws.com/app-codepipeline-template.json) as a base template. Since I don't need most of this infrastructure, I'll trim it down to the core requirements. I also need to adjust some CodePipeline settings, documented [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codepipeline-pipeline.html) ([link 2](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-actions.html), [link 3](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-actions.html#cfn-codepipeline-pipeline-stages-actions-actiontypeid), [link 3](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#actions-valid-providers)). For configuration, see [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-actions.html#cfn-codepipeline-pipeline-stages-actions-configuration), and more specifically, [here](https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeCommit.html#action-reference-CodeCommit-config).

The build pipeline will have two stages:

- [x] The first stage should be called Source, and it will be configured to pull source code from the repo.
- [x] The second stage should be called Build, and it will take the source code and build it using CodeBuild.

The pipeline configuration references a special IAM service role (CodePipelineServiceRole) to access other AWS services. The recommended configuration code was copy-pasted into my json.

#### Test Pipeline

Trigger the pipeline. The source and build stages should complete. 

#### Manual Approval Stage

I'll try to add a manual approval to the pipeline. This would, for instance, let the pipeline do a series of automated tasks, then pause while you do some manual tests on the build artifact, before resuming upon approval.

**I did not achieve my goal here. The latest file versions were:**

app-codepipeline-template_updating_noapprove.json - this is working, without any Approval Stage

crazy.json - tried something crazy, before moving to minimal. I can't recall what.

minimal.json - latest attempt, stripping out everything I can.

## Upload to Repo

I'm just using the browser to add the files to github. Nothing in CLI.