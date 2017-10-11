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