---
title: Introduction to CloudFormation
weight: 2
---

CloudFormation is the main AWS service to create, change and update your AWS infrastructure. It provides a configuration syntax to define your resources and a service that will automatically create, update or remove resources to match changes in your template file.

CloudFormation seems very complex to get started with, but once you understand some core concepts the complexity becomes a lot less daunting. In this guide you will learn the basics of CloudFormation templates, how to use Change Sets to bring more safety, reliability and insights into your CloudFormation deployments and which tools to use to work with CloudFormation.

## Tool Suite

The Serverless Way Tool Suite provides several tools to work with and deploy to CloudFormation. Before diving into the guides it is definitely helpful to learn the basics of the tools so you can deploy everything while

With [Formica](/tools/formica) you can easily deploy CloudFormation template files that follow a naming pattern. It allows you to split your template files to keep them small and even has built-in modularity to so you don't have to repeat often used resource configurations. Check out the [quick start guide](/tools/formica#quick-start-guide) for an introduction.

[AWSInfo](/tools/awsinfo) is the easiest way to get information about your deployed resources in your cli. You never have to go into your AWS Console again and switch from productive CLI use to unproductive web browsing.

It implements easy filtering, so you don't have to remember exact names of resources to show. So if we deployed a Stack and want to list all its outputs, but don't want to type the whole name just type part of it and AWSInfo will figure out the rest (if it matches multiple it will select the first and list all others as well)

```
# awsinfo cfn resources prod
Selected Stack tslw-production
-----------------------------------------------------------------------------------------------------------------------------
|                                                    ListStackResources                                                     |
+-------------+------------------------------------------+------------------+------------------+----------------------------+
| 1.LogicalId |              2.PhysicalId                |     3.Type       |    4.Status      |       5.LastUpdated        |
+-------------+------------------------------------------+------------------+------------------+----------------------------+
|  DevBucket  |  tslw-production-devbucket-zpado4bv5jrq  |  AWS::S3::Bucket |  CREATE_COMPLETE |  2017-10-04T14:20:17.112Z  |
|  WebBucket  |  tslw-production-webbucket-2recxkzqu0z6  |  AWS::S3::Bucket |  CREATE_COMPLETE |  2017-10-04T14:20:16.830Z  |
+-------------+------------------------------------------+------------------+------------------+----------------------------+
```

And best of all it's just a layer on top of the AWS CLI, so if you want a command to do something a bit different you can check out the code and adapt it to your needs in seconds.
