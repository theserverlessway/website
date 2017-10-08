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
        -
          Action:
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

IAM is the main service in AWS to authorise access to your resources. You can use Users, Groups and Roles to properly organise your account.

## Authorisation syntax