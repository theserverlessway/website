---
title: AWS CLI basics
weight: 1
---

Following is a brief introduction to some basics of the AWS CLI as well as more advanced options like the `--output` and especially the `--query` option.

The AWS Cli is written in Python and uses the [boto3](TODO) library as its interface to AWS. Boto3 is a very powerful and elegant library if you want to interact with AWS in your code.

In case you haven't already set up your AWS Credentials please follow the [AWS CLI docs](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) for setting up your basic credentials.

### How to call the AWS CLI

The basic command structure of the AWS CLI is

```
aws [options] <command> <subcommand> [parameters]
```

e.g.

```
aws cloudformation describe-stacks --stack theserverlessway
```

by adding `help` to the end of a command you can get the help output, e.g.

```
aws cloudformation help
```