# AWS CloudFormation

2019.11.09
Garth Mortensen

## Note

It's important to find your interests, and also your non-interests. You have to draw a line somewhere. For me, DevOps a non-interest. It seems to be so much GUI work, and limited coding work. The concern I have is that AWS is always changing their user interface, meaning that what I'm learning will have a short shelf-life. AWS is all clickity-click and no clackity-clack. Of course, this _is_ my first real foray into AWS code automation, so perhaps the following work will change my mind. 

## Background

[CloudFormation]( https://aws.amazon.com/cloudformation/) is AWS' infrastructure definition tool for automating the deployment of cloud infrastructure. It's used by services such as Elastic Beanstalk and ECS.

You start with a CloudFormation **template**, which used to only be .json, but they now support .yml. Templates can be version controlled. The set of resources created by the template are called the **stack**. The templates make API calls to AWS, and your credentials are used to provision.

1. Create template
2. Store it in S3 bucket
3. AWS CloudFormation creates the stack.

![CloudFormation Illustration]( https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/images/create-stack-diagram.png )

### Template 

#### Parameters

Input values.

> “Parameters” {
> 	“**InstanceTypeParameter**” : {
> 		“Type” : “String”,
> 		“Default” : “t2.micro”,
> 		“AllowedValues” : [“t2.micro”, “t2.small”, “t2.medium”],
> 		“Description” : “Enter the instance type (t2.micro, t2.small, or t2.medium).”
> 	}
> }

#### Outputs

These are like function returns. Not always needed.

> "Outputs" : {
> 	"Logical ID" : {
> 		"Description" : "Information about the value",
> 		"Value" : "Value to return"
> 	}
> }

### CloudFormation Features

A. Intrinsic Functions

1. Fn:FindInMap. _"Fn::FindInMap" : [ "MapName", "TopLevelKey", "SecondLevelKey"]_
2. Fn:GetAtt. _"Fn::GetAtt" : [ "MyLoadBalancer" , "DNSName" ]_
3. AZ. _{ "Fn::GetAZs" : { "Ref" : "AWS::Region" } }_
4. Ref. _"Ref" : "logicalName”_
5. Conditional. _"Fn::If": [condition_name, value_if_true, value_if_false]_

B. [Pseudo Parameters](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html). Full list available [here]( https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html), I think.

1. AWS::AccountId. _returns AWS account ID in which stack is created_
2. AWS::Region. _returns a string representing the AWS region for the stack_
3. AWS::StackName. _returns the name of the stack_

## Task

The engineering manager at your office came to you and asked if you could build a new CloudFormation stack template called **corpweb.json** for the development team. The stack must have **two Amazon Linux EC2** instances located behind an Application **ELB**. The load balancer must handle incoming requests on **port 80** and send those to the EC2 instances on **port 80**. Additionally, the two instances need to be members of a **security group** which allows incoming traffic on ports **22** and **80**.



[ELB Setup](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-elasticloadbalancingv2-listenerrule.html)



