---
title: Query Option
weight: 2
---

Large JSON Files are great for automated processing, but hard to read and understand. By default the AWS CLI presents its users with large to very large JSON output that is simply unusable for your everyday work. Thats why many people still rely on the AWS Console to get information about their deployed resources, when this is very unproductive. You have to leave your editor and terminal to go look up some information in the AWS Console that could be easily shown in your terminal as well.

The `--query` option allows you to use [JMESPATH](http://jmespath.org/), a JSON query language, to limit and select the JSON attributes from an awscli command. This makes it easy to limit the JSON response to the data you're actually interested in.

The following very simple example will only select the names of CloudFormation stacks from the larger `aws cloudformation describe-stacks` call.

```
# aws cloudformation describe-stacks --query "Stacks[].StackName"
[
    "tslw-website",
    "tslw-backend"
]
```

This together with the `--output` option and its text or table output give you a lot of control over how to present information from the AWS CLI. They can be easily chained together to build powerful tools, for example [awsinfo](/tools/awsinfo) is written completely in bash and uses the `--query` option extensively to give you quick access to the most important information on your AWS resources. You can also check out the [awsinfo code](https://github.com/flomotlik/awsinfo/tree/master/scripts/commands) to see many examples of JMESPath.

This makes it even clearer that the AWS CLI is great as a Shell SDK. You can easily write shell scripts or Makefiles that call the AWS CLI with the `--query` and `--output` option.

## JMESPath

As the Query language behind the `--query` option JMESPath is a very powerful language. The following examples cover some of the more common use cases when used with the AWS CLI, but JMESPath can do way more than this. There is also a [great tutorial](http://jmespath.org/tutorial.html) and [collection of examples](http://jmespath.org/examples.html) on their page, though it can be a bit overwhelming at first.

### Selecting a property from a list of resources

The same as the example above where we just want to know the `StackName` for every Stack. `[]` (you can also use `[*]`) after `Stacks` will iterate over all stacks in the `Stacks` array and select the properties of each.

```
# aws cloudformation describe-stacks --query "Stacks[].StackName"
[
    "tslw-website",
    "tslw-backend"
]
```

### Select a property from a list of resources with each property in its own list

This is important when you use `--output text` as it will put every `StackName` in its own line so they can be processed by other tools like xargs, sed, or awk.

```
# aws cloudformation describe-stacks --query "Stacks[].[StackName]"
[
    [
        "tslw-website"
    ],
    [
        "tslw-backend"
    ]
]
```

### Create a new Hash with properties from a list of resources (JMESPath calls this a Hash Projection)

This is especially helpful when you use the `--output table` option as it allows you to name the columns of your table and thus decide on the order. We're adding a number before every field as `--output table` sorts the columns by name. If you want to add numbers and a `.` separator you have to put the hash key in `""`. This example is taken directly from [awsinfo](/tools/awsinfo) where it is used for the `awsinfo cfn` command.

```
# aws cloudformation describe-stacks --query "Stacks[].{\"1.Name\":StackName,\"2.Status\":StackStatus,\"3.CreationTime\":CreationTime}"
[
    {
        "1.Name": "tslw-website",
        "2.Status": "CREATE_COMPLETE",
        "3.CreationTime": "2017-03-23T15:25:11.082Z"
    },
    {
        "1.Name": "tslw-backend",
        "2.Status": "UPDATE_COMPLETE",
        "3.CreationTime": "2017-02-10T13:13:24.004Z"
    }
]
```

JMESPath doesn't have a shorthand syntax for selecting properties and reusing the property name as key (something like `--query Stacks[].{StackName, StackStatus}`), so you have to set the hash keys yourself, even if they should have the same name as the property already has.

### Create a new List with properties from a list of resources (JMESPath calls this a Hash Projection)

This is especially helpful when you use the `--output text` option together with text processing tools like awk as it will print out each sublist on a tab separated line.

```
# aws cloudformation describe-stacks --query "Stacks[].[StackName, StackStatus, CreationTime]"
[
    [
        "tslw-website",
        "CREATE_COMPLETE",
        "2017-03-23T15:25:11.082Z"
    ],
    [
        "tslw-backend",
        "UPDATE_COMPLETE",
        "2017-02-10T13:13:24.004Z"
    ]
]
```

### Select a property only from resources passing a filter (JMESPath calls this a Filter Projection)

In this example we're only interested in Stacks that match `CREATE_COMPLETE`, you can also use `!=`, `<`, `>` or many other [comparison operators and functions](http://jmespath.org/specification.html#filterexpressions)

```
# aws cloudformation describe-stacks --query "Stacks[?StackStatus=='CREATE_COMPLETE'].StackName"
[
    "tslw-website",
]
```

### Use functions in a Filter

JMESPath supports [many different functions](http://jmespath.org/specification.html#built-in-functions) that you can use in your query. They are especially helpful in Filters. In the following example we're only interested in stacks where the `StackName` contains `backend`. Of course we could then combine this with a more complex query like above to select different properties and build a complex hash.

```
# aws cloudformation describe-stacks --query "Stacks[?contains(StackName,'backend')].StackName"
[
    "tslw-backend",
]
```

This is used extensively in [awsinfo](/tools/awsinfo) to allow you to give only part of a resource name and match all resources that have the part in their name (or other properties depending on the resource).

### Sort resources by a property

In this example we're sorting by `CreationTime` and you can see the results are sorted differently than in the example before.

```
# aws cloudformation describe-stacks --query "sort_by(Stacks,&CreationTime)[].{\"1.Name\":StackName,\"2.Status\":StackStatus,\"3.CreationTime\":CreationTime}"
[
    {
        "1.Name": "tslw-backend",
        "2.Status": "UPDATE_COMPLETE",
        "3.CreationTime": "2017-02-10T13:13:24.004Z"
    },
    {
        "1.Name": "tslw-website",
        "2.Status": "CREATE_COMPLETE",
        "3.CreationTime": "2017-03-23T15:25:11.082Z"
    }
]
```

## Developing and Debugging JMESPath queries

Developing complex JMESPath queries can be quite slow when you have to call the AWS CLI constantly. To solve this there is the [`jp` command line tool](https://github.com/jmespath/jp) which is a Go implementation of JMESPath. Because you can run it on your local system it obviously speeds up development and debugging considerably.

In the following example we're storing the JSON file from `aws cloudformation describe-stacks` in a stacks.json file first and then use jp to read the file and interpret the output.

```
# aws cloudformation describe-stacks > stacks.json
# jp -f stacks.json "Stacks[].StackName"
[
    "tslw-website",
    "tslw-backend",
]
```

As the JSON file is now read from the local filesystem this is of course very fast.

The [official JMESPath page](http://jmespath.org/) also has a browser JMESPath evaluation feature, but its a bit cumbersome to use in comparison to simply running in your local terminal.