---
title: Templates
weight: 1
---

This basic CloudFormation Template guide will walk you through the most important parts of your CloudFormation template. Its mostly geared towards newcomers to CloudFormation, but even more experienced CloudFormation users should be able to pick up a few things. The other parts of the CloudFormation guide will be a bit more advanced, so feel free to skip if you feel you've already learned the basics of CloudFormation templates.

For a full documentation of every option check out the [Template Anatomy Documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html).

CloudFormation templates are the main configuration to building your infrastructure. They describe all the resources and can take inputs through Parameters.

CloudFormation then takes the update to a template, computes a ChangeSet and executes those computed changes.

The main Elements of your Template are:

* Resources - for your AWS resources
* Parameters - for providing parameters during deployment
* Conditions - to only build resources in specific situations
* Outputs - to either get information about a deployed resource or make them available in other stacks through export/import

For the following example we'll create a S3 Bucket that will host a Website. If you want to deploy those examples as well the simplest way is to use [Formica](/tools/formica).

## Resources

The basic setup of a Resources is the following (taken directly from the docs):

```yaml
Resources:
  Logical ID:
    Condition: Optional Condition
    Type: Resource type
    Properties:
      Set of properties
```

In the following example we're creating an S3 Bucket that has the WebsiteConfiguration enabled. Because we're not setting a `BucketName` S3 will automatically generate one for us.

```yaml
Resources:
  WebBucket:
    Type: "AWS::S3::Bucket"
    Properties:
      AccessControl: PublicRead
      WebsiteConfiguration:
        IndexDocument: index.html
```

### Automated name generation

CloudFormation supports automated random names for many different resources. Generally it's a best practice to use automated names wherever possible and then reference the `LogicalId` of a resource inside the template. If you give your resource specific names (e.g. the S3 Bucket) some resources could potentially clash if the stack gets deployed a second time.

For example S3 bucket names have to be unique across all of S3. If you rely on a specific name of a bucket in your infrastructure you're inevitably going to run into issues with that.

### Looking up resource details

When writing CloudFormation templates you will constantly look up the properties and specific names of your resources. To help with that you have a few different options:

1. Save the [Resource Types Reference](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html) in your Browser so you can be there quickly.
2. Use `former` from our Tool Suite to get all attributes of a specific type in your command line. Check out the [former docs](TODO) for more information and a tutorial.
3. If you're on a Mac buy [Dash](https://kapeli.com/dash) and get an offline documentation browser. It's great and will improve your productivity a lot.

### Links

* [Resources documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/resources-section-structure.html)
* [Resource Types Reference](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)

## Parameters

Parameters allow you to pass values during deployment to customize your stack. They can be of different types to provide basic input validation and can be used together with conditions to select which resources should be created when.

We'll add a Parameter to specify our `WebBucketName` for our WebBucket. We can use that Parameter through the `Ref` function, which we'll describe in more detail later. In this case we're using `!Ref` which is a shortcut AWS built into their yaml parsing so we don't have to nest the `Ref`.

```yaml
Parameters:
  WebBucketName:
    Type: String
Resources:
  WebBucket:
    Type: "AWS::S3::Bucket"
    Properties:
      BucketName: !Ref WebBucketName
      AccessControl: PublicRead
      WebsiteConfiguration:
        IndexDocument: index.html
```


Parameters support many different types like `String`, `Number` or `CommaDelimitedList`. Check out the types in the [Parameters Documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html) for all details.

Parameters also support a lot of other properties like `Default` (which we'll use in a second), `AllowedValues` or `MinLength`. Make sure you read through all the different properties in the [Parameters Documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html).

### Links

* [Parameters Documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)

## Conditions

Conditions allow you to do two things:

* Create resources when the condition is met
* Use the CF template `If` function in your template to set (or remove) specific properties depending on the condition.

For our template we want to add an additional `DevBucket` so we can deploy into a dev environment. That bucket should be created by default, but we should also be able to disable the behaviour.

As CloudFormation Parameters don't support a boolean type we'll use a `String` type that only allows true or false. We set a `Default` value of true, so it will be created.

```yaml
Parameters:
  WebBucketName:
    Type: String
  CreateDevBucket:
    Default: true
    Type: String
    AllowedValues: [true, false]
Conditions:
  CreateDevBucket:
    !Equals [true, !Ref CreateDevBucket]
Resources:
  WebBucket:
    Type: "AWS::S3::Bucket"
    Properties:
      BucketName: !Ref WebBucketName
      AccessControl: PublicRead
      WebsiteConfiguration:
        IndexDocument: index.html
  DevBucket:
    Type: "AWS::S3::Bucket"
    Properties:
      AccessControl: PublicRead
      WebsiteConfiguration:
        IndexDocument: index.html
```

But the WebBucket still requires `WebBucketName` to be set, which goes against what we described above with auto-generated names. We can change the template to allow `WebBucketName` to be optional by setting the `Default` to an empty string.

CloudFormation doesn't allow us to use the empty string in the `BucketName` though, so we have to use an `If` together with the `AWS::NoValue` built-in to let CloudFormation know to simply remove that Property from the template. It will be treated as if it were never set, thus telling CF to auto-generate the `BucketName`

The syntax for the different built-in functions (`If`, `Equal`, `Not` in this case) are a bit confusing at first, as you have to use lists or sometimes lists of lists. For more details check out the [built-in functions guide](TODO).

```yaml
Parameters:
  WebBucketName:
    Type: String
    Default: ''
  CreateDevBucket:
    Default: true
    Type: String
    AllowedValues: [true, false]
Conditions:
  CreateDevBucket:
    !Equals [true, !Ref CreateDevBucket]
  HasWebBucketName:
    !Not [!Equals ['', !Ref WebBucketName]]
Resources:
  WebBucket:
    Type: "AWS::S3::Bucket"
    Properties:
      BucketName: !If [HasWebBucketName, !Ref WebBucketName, !Ref 'AWS::NoValue']
      AccessControl: PublicRead
      WebsiteConfiguration:
        IndexDocument: index.html
  DevBucket:
    Type: "AWS::S3::Bucket"
    Condition: CreateDevBucket
    Properties:
      AccessControl: PublicRead
      WebsiteConfiguration:
        IndexDocument: index.html
```

For more information check out the [AWS Conditions Documentation](TODO) and take a look at our [Condition Examples] for standard use cases and examples for conditions.

## Outputs

Outputs allow you to:

1. View values created by your CloudFormation template
2. Export values to be later imported by other stacks

Often its helpful for your Stack to export some values that can be read by the developers after the stack has been deployed or updated. This can include attributes of resources or other significant values.

For the following example we want to get the `WebsiteUrl` for our web and dev bucket so we can access the website after deployment. Most Resources allow you to access attributes of the deployed resource through the [`GetAtt` function](TODO). The `!GetAtt RESOURCE.ATTRIBUTE` syntax is a shorthand available in yaml files.

You can find those values in the `Return Values` section of each [Resource documentation page](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)

When we look up the [S3 Bucket Return Values](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-bucket.html#aws-properties-bucket-ref) we can see it allows us to return (among other things) the `WebsiteURL`. In our Outputs section we can now add Outputs for both our web and dev bucket. The dev output is of course only added if the `CreateDevBucket` conditional is true.

```
Outputs:
  WebBucketURL:
    Description: URL for the website bucket
    Value: !GetAtt WebBucket.WebsiteURL
  DevBucketURL:
    Description: URL for the development bucket
    Condition: CreateDevBucket
    Value: !GetAtt DevBucket.WebsiteURL
```

In the Value field you're not limited to `Ref` or `GetAtt` but can use any [built-in function] or even just a string (which can be helpful for deployment tools to add metadata to a deployment).

After redeploying with the above yaml config added you should see the URLs as part of the Stack Outputs.

* [Output Documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html) in the official AWS Documentation.


### Export/Import

A great feature of CloudFormation for organising your resources in separate stacks is the export/import feature. It allows to export data from one stack and import it in another. As long as another stack is importing values the stack that exported them can't be removed and neither can the exported outputs themselves.

We're using the [`!Sub` function](TODO) as it is the easiest way to combine values into a string. It's considered a best practice to add the stack name as a prefix of the exported name. `AWS::StackName` is one of several [Pseudo Parameters](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html) AWS supports in CloudFormation templates.

```
Outputs:
  WebBucketURL:
    Description: URL for the website bucket
    Value: !GetAtt WebBucket.WebsiteURL
    Export:
      Name: !Sub ${AWS::StackName}:WebsiteUrl
  DevBucketURL:
    Description: URL for the development bucket
    Condition: CreateDevBucket
    Value: !GetAtt DevBucket.WebsiteURL
```

Once we deployed this (e.g. into a stack named `test-stack`) into a stack we can see that the `WebBucketURL` Output was also exported as `test-stack:WebsiteUrl`.

In another stack we can now import the value with `!ImportValue test-stack:WebsiteUrl` and will get the same `WebsiteURL` that we got in our deployed template.