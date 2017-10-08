---
title: Template Functions
weight: 2
---

CloudFormation supports built-in functions in your templates. Those range from referencing other resources to building custom strings or importing values from other stacks.

In the following sections we'll go through the functions you'll use most often with a few practical examples. Check out the [full template functions documentation](TODO) for all supported functions.

For YAML template files AWS allows for a shorthand syntax. Instead of writing

```
BucketName:
  Ref: WebBucketName
```

you can use

```
BucketName: !Ref WebBucketName
```

The same applies to other functions that have to be prepended with `Fn::` in normal syntax, but can be used without in shorthand.

```
Fn::Sub: ${WebBucket.Arn}*
```

can be written as

```
!Sub ${WebBucket.Arn}*
```

All example in this doc will use the shorthand yaml syntax. For other syntax options please check the [official docs](TODO)

## Ref

Ref is used to reference other resources or parameters in your template. Depending on the Resource it will return what data is typically needed the most from that resource. For example for a S3 Bucket it returns the bucket name, for an ACM Certificate it will return the ARN.

Every resource in the CloudFormation documentation has `Ref` docs in the `Return Value` section that documents what the return value is.

In the template docs before we used the following to reference the WebBucketName parameter:

```
BucketName: !Ref WebBucketName
```

## GetAtt

Most resources allow you to access further information beside what is available thorugh `!Ref`. You will use those all the time to make resources work together. In the template docs example we used it to access the S3 Buckets WebsiteUrl.

The YAML shorthand syntax allows you to specify the resource and attribute through `!GetAtt RESOURCE.ATTRIBUTE`.

```
Value: !GetAtt WebBucket.WebsiteURL
```

The documentation for each resource has a `Return Values` section that documents all the different values you can access.

## Sub

Through the `Sub` function you can build a string and substitue parts of it with values from variables. Those variables can be anything from results of `!Ref` or `!GetAtt` calls to using `!If` to set variables depending on template parameters.

The most common use cases we see for `!Sub` are:

* Create a string that you want to embed results from `!Ref` or `!GetAtt` into
* Create large text that you want to parameterize, e.g a config file for an EC2 instance

### Embedding Ref or GetAtt

The !Sub Shorthand Syntax has another neat trick when you only want to use return values accessible through `!Ref` or `!GetAtt`. By putting the resource name into `${RESOURCE}` you can get the same result as with `!Ref` and through `${RESOURCE.ATTRIBUTE}` you can access the values you could get with `!GetAtt`.

For example lets say we want to write an IAM policy that allows access to all files in a bucket. To do that we need the ARN of the bucket and then add a wildcard at the end of that ARN. By using the `!Ref` value of the bucket we can get the bucket name and build the ARN.

```
Action:
  - "s3:GetObject"
Effect: "Allow"
Resource:
  - !Sub arn:aws:s3:::${WebBucket}/*
```

It will replace `${WebBucket}` with the bucket name during deployment.

As the S3 Bucket resource now supports getting the ARN through `!GetAtt` we can also write this shorter. We want to access every file in the bucket so we have to add the wildcard.

```
Action:
  - "s3:GetObject"
Effect: "Allow"
Resource:
  - !Sub ${WebBucket.Arn}/*
```

```
Action:
  - "s3:GetObject"
Effect: "Allow"
Resource:
  - !Sub arn:aws:s3:::${WebBucket}/*
```

### Building larger config files with variables

In large config files you often have to embed both resources, parameters and arbitrary strings. In the following example we're doing a few helpful things.

First of all we're using the yaml multiline string syntax with `- |`. That allows us to embed the file while still making it readable in the template.

Next we're using two variables in the config file string, `InstallBucket` and `InstallFile`. InstallFile here would reference a parameter. It's not included in this particular example, but easy to imagine.

`InstallBucket` though is a bit more complex as it uses ImportValue to get the value for the variable.

```
UserData:
  Fn::Base64:
    !Sub
      - |
        #!/bin/bash -xe
        yum update -y aws-cfn-bootstrap
        aws s3 cp s3://${InstallBucket}/${InstallFile} install_file
        bash install_file
      - InstallBucket:
          Fn::ImportValue: "install-stack:InstallBucket"
```

Now this is a simple example of what you can do in the Variables. It can go to any complexity you want as it allows you to use most other functions CloudFormation provides.

## Split

## ImportValue

