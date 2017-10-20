---
title: Introduction to IAM
weight: 3
---

There are two ways you can allow access to your resources in AWS. Either by setting policies directly on resources or by allowing specific IAM entities to access those resources.

## Resource based authorisation

S3 is an example that supports resource based policies. Every S3 bucket can have policies attached that can authorise access.

In the following example we're allowing access to files in an S3 Bucket from theserverlessway.com. We'll describe the details of the different parts of this policies in more detail later on.

```
WebBucketPolicy:
  Type: "AWS::S3::BucketPolicy"
  Properties:
    Bucket: !Ref WebBucket
    PolicyDocument:
      Statement:
        - Action:
            - "s3:GetObject"
          Effect: "Allow"
          Resource:
            - !Sub ${WebBucket.Arn}/*
          Principal: "*"
          Condition:
            StringLike:
              aws:Referer:
                - "https://theserverlessway.com/*"
```

## IAM based authorisation

IAM is the main service in AWS to authorise access to your resources. You can use Users, Groups and Roles to properly organise your account. Users and Groups allow you to control access to resources for your development team. It's considered best practice to only allow Groups to access resources and then add Users to those groups.


### Roles

Roles can be assumed by resources, so for example your EC2 instance or ECS container service can run as that specific role. Roles are the primary way to authorise access in your infrastructure.

Roles have to be specific to a use case. Never reuse roles or use them for multiple resource authorisations. Through automation you can easily create roles together with any of your resources, so make sure you do.

### Policies

There are 3 different kinds of policies:

1. AWS managed policies
2. Self managed policies
3. Inline policies


AWS managed policies are created and maintained by AWS and can be added to any Identity (Users, Groups or Roles). There are policies for many different use cases, from admin access to billing access. Make sure you look through them before creating your own.

Self managed policies can also be attached to any Identity, but are created by you. Self-managed policies are especially useful to create them together with the resources they authorise. You can then export those managed resources in CloudFormation and include them somewhere else. This makes it possible for the person or team that creates a resource to also create the access authorisation.

### Authorisation syntax

Following is an example of a policy with 2 items in the statement and with the most important attributes set. It includes the most important elements with `Effect`, `Action`, and `Resource`. A policy can include multiple statements

```
Statement:
  - Effect: Allow
    Action: s3:ListBucket
    Resource: !GetAtt WebBucket.Arn
  - Effect: Allow
    Action: s3:GetObject
    Resource: !Sub ${WebBucket.Arn}/*
```

* ***Effect***: Either Allow or Deny access when the statement matches. A Deny will always override an Allow defined in another statement.
* ***Action***: The action or list of actions allowed for accessing a resource
* ***Resource***: The ARN or list of ARNs to allow or deny the actions on

Policy statements can also include other attributes like `Principal` but those are much rarer in use than the ones mentioned above. Do check out the whole reference though once you get a good understanding of the basics though to be able to fully understand what you can do with IAM policies.

[IAM Policy syntax reference](http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html)

## Wildcards

Policies in IAM support wildcards, making it possible to create policies that match multiple resources or can include random names in their resource ARNs. An important thing to understand about ARN and IAM is that IAM will do simple string matching of a resource ARN against a request.

Wildcards can either be `*` for a combination of characters or `?` for a single character. You will use `*` way more often than `?`.

So for example if you want to access the file `/reports/somereport.xml` in an S3 bucket `acme-sales-reports` IAM will check if there is a policy in place allowing you to access the following ARN: `arn:aws:s3:::acme-sales-reports/reports/somereport.xml`.

As every file in an S3 Bucket has its own ARN and you can grant access to them individually this has to be taken into account when writing your IAM policies (same applies for other AWS services of course). While this is a simple idea it's an important one to fully understand as this allows to build least privilege policies to really only grant access to resources you need to give access to.

For example access to the file mentioned above could be done by all of the following resource definitions:

```
arn:aws:s3:::acme-sales-reports/*
arn:aws:s3:::acme-sales-reports/reports/somereport.xml
arn:aws:s3:::acme-sales-reports/reports/*.xml
arn:aws:s3:::acme-sales-reports/reports/some*.*
arn:aws:s3:::acme-sales-reports/reports/some*.*
arn:aws:s3:::acme-*-reports/reports/some*.*
arn:aws:s3:::acme?sales?reports/reports/some*.*
```

Because we're adding the department the bucket belongs to (*sales*) we can also write IAM policies that would allow access to all buckets of the sales organisation for example. Naming your AWS resources well and consistent is very important to make sure you can rely on those names for your IAM rights.

As IAM does a simple expansion on wildcards they are a very powerful, but also dangerous. A misplaced or too widely used wildcard could open up more resources than you want. This could allow an attacker, or even just an accident, to have much broader impact than necessary.

Of course wildcards can also be used in the `!Sub` function as we've seen in an earlier example `!Sub ${WebBucket.Arn}/*`

#### Wildcards with CloudFormation random names

Wildcards are very helpful when used together with CloudFormation random names. Many resources provide you with a way to access the ARN, but sometimes this isn't possible and you have to build it yourself. Through wildcards and stack name use you can create ARNs that use wildcards but are still specific enough. Sometimes this might also be necessary because of circular dependencies between CloudFormation resources you have to entangle.

Lets look at the following S3 Bucket that was created randomly. The CloudFormation stack is named `tslw-infrastructure` and the Logical Id of the Bucket is `TheserverlesswayComWebBucket`. CloudFormation combines this together with a random string to create the actual bucket:

```
tslw-infrastructure-theserverlesswaycomwebbucket-jui23u765f98u
```

A matching IAM resource should include the stack name and the logical name, but use a wildcard for the random part. We can use `AWS::StackName` to dynamically fill that part so the same stack can be deployed separately as well:

```
!Sub arn:aws:s3:::${AWS::StackName}-theserverlesswaycomwebbucket-*
```

This resource definition will always match the specific bucket in this stack, unless someone specifically creates a bucket following the same naming pattern, but different random part in the end. Because of this its still advisable to use `!Ref` or `!GetAtt` wherever possible to get full ARNs and not use wildcards, but sometimes you have to work around it.