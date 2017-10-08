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

Now this is a simple example of what you can do in the Variables. It can go to any complexity you want as it allows you to use most other functions CloudFormation provides. Check out the [full documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-sub.html) for all details.

## Select

Select allows you to select one item from a list. Its especially helpful to use with the Split function.

You can use

## Split and Join

`Split` and `Join` allow you to split a string into a list of elements and join a list back into a string.

### Join

With `Join` you can take a list of elements and turn them into a string, for example a list of SecurityGroups into a comma separated string output:

```
Outputs:
  LoadBalancerSecurityGroups:
    Description: Security Groups associated with our Main Loadbalancer
    Value: !Join [',', !GetAtt LoadBalancer.SecurityGroups]
```

### Split

The most common use case with `Split` we've come across so far is splitting a value requested from either a resource in the same template or after importing it from another stack.

For example when we create a S3 Bucket that hosts a static website and we want to put that bucket behind a CloudFront distribution. To configure CloudFront we need to get the domain name of the S3 Web Bucket. The return value of the `!GetAtt` call to the S3 Bucket returns the full URL though, which means we somehow have to get rid of the `https://` prefix. This can be accomplished thorugh `Split` and `Select`.

The following code is taken right from the infrastructure definition of TheServerlessWay.com:

```
Origins:
  - DomainName: !Select [2, !Split ['/', !GetAtt 'WebBucket.WebsiteURL']]
```

Of course we could also use `!Sub` to build the URL ourselves as it has a well known format, but this is simply a cleaner solution. And this same pattern can be used for any return value of any resource. Combined with `!Sub` you could even build a more complex string that splits a return value and selects a few different parts and assembles them through variables in a `!Sub` string.

Another common usecase is splitting an imported Value. CloudFormation Outputs have to be strings, so if you want to output a list of items you have to `Join` them into a string. After importing them we can use `Split` to get separate items and use the list (or select one of the items in the list):

```
!Split [",", !ImportValue loadbalancer-stack:SecurityGroups]
```

```
!Select [2, !Split [",", !ImportValue loadbalancer-stack:SecurityGroups]]
```

Check out the [full Split documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-split.html) for all details on the `Split` function.

### Extending a list with Split and Join

Sometimes you want to put a comma separated list of parameters into a stack or import a comma separated string from another stack, but then add additional elements to that list before using them with a resource.

For example you want to associate a LoadBalancer or an EC2 Instance with several SecurityGroups that get created in different stacks.

CloudFormation doesn't have an easy way to extend a list, so we have to work around this with `Join` and `Split`. In the following example we have a parameter `WebSecurityGroups` that we want to extend with a resource `SecurityGroup` that gets created in that same stack. To combine them we first have to use `Join` to turn the `WebSecurityGroups` parameter into a comma separated string. Then with another `Join` we append the `SecurityGroup` resource to that list. Now we have a comma separated string of the SecurityGroups we want and can use `Split` to turn it from a string into a list.

```
Parameters:
  WebSecurityGroups:
    Type: CommaDelimitedList

Resources:
  SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
        ...

  LoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      SecurityGroupIds: !Split
        - ','
        - !Join
            - ','
            - - !Join [ ',', !Ref WebSecurityGroups ]
              - !Ref SecurityGroup
```

This doesn't look particularly nice but it works and it isn't too complex. We could also make `WebSecurityGroups` optional and use a Condition together with an If when joining the two together.

## ImportValue

ImportValue is pretty straight forward, you tell it which Export it should import and it will return that string. You can then use other functions like in the examples above to split or join this imported value further.

```
!Split [",", !ImportValue loadbalancer-stack:SecurityGroups]
```