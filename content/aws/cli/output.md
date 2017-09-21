---
title: Output Argument
weight: 3
---

By default the AWS CLI prints your results in JSON, but through the `--output` option you can change that to more human readable formats.

The `--output text` option is very helpful if you want to use further text processing tools like [sed](), [awk]() or simply grep the results.

With `--output table` you can get a human readable table version of your data which will print the JSON a command returns as a table.

## Text Output

Text Output will print a line for each item in a list and separate the properties with tabs. When it finds a hash it will not print they key, but only the values, making the following examples equivalent:

```
# aws cloudformation describe-stacks --query "Stacks[].[StackName,StackStatus,CreationTime,LastUpdatedTime]" --output text
tslw-backend UPDATE_COMPLETE 2017-02-10T13:13:24.004Z
tslw-website CREATE_COMPLETE 2017-03-23T15:25:11.082Z

# aws cloudformation describe-stacks --query "Stacks[].{\"1.Name\":StackName,\"2.Status\":StackStatus,\"3.CreationTime\":CreationTime}" --output text
tslw-backend UPDATE_COMPLETE 2017-02-10T13:13:24.004Z
tslw-website CREATE_COMPLETE 2017-03-23T15:25:11.082Z
```

This can then be used together with awk and grep to do further processing, for example by selecting the name and creation date of stacks that were created or updated in March 2017:

```
# aws cloudformation describe-stacks --query "Stacks[].[StackName,StackStatus,CreationTime,LastUpdatedTime]" --output text | grep "2017-03" | awk '{print $1 " " $3}'
tslw-website 2017-03-23T15:25:11.082Z
```

Make sure to always enclose the selected property in `[]`, so you get a list of lists as an output, otherwise `--output text` will print all results on the same line. The following example at first omits the additional list syntax, thus results are on the same line, the second example is corrected and prints each result on a new line.

```
# aws cloudformation describe-stacks --query "Stacks[].StackName" --output text
tslw-website    tslw-backend

aws cloudformation describe-stacks --query "Stacks[].[StackName]" --output text
tslw-website
tslw-backend
```

## Table Output

Table output creates a nice human readable form for your JSON output. It supports hashes and lists and both can even be embedded. The table output can become very complex quickly when the result of a command contains a mix of lists and hashes. In those cases make sure to use `--query` to limit the output to the desired properties to make it easier to understand.

If the result of your command and query is a hash it takes the hash keys as column names:

```
# aws cloudformation describe-stacks --query "Stacks[].{\"1.Name\":StackName,\"2.Status\":StackStatus,\"3.CreationTime\":CreationTime}" --output table
-------------------------------------------------------------------------------------------
|                                     DescribeStacks                                      |
+-------------------------------+----------------------------+----------------------------+
|            1.Name             |         2.Status           |      3.CreationTime        |
+-------------------------------+----------------------------+----------------------------+
|  tslw-website                 |  CREATE_COMPLETE           |  2017-03-23T15:25:11.082Z  |
|  tslw-backend                 |  UPDATE_COMPLETE           |  2017-02-10T13:13:24.004Z  |
+-------------------------------+----------------------------+----------------------------+
```

In case you don't want to set specific headers you can also simply create a list of properties, although for commands you run regularly, especially when they are in scripts, we advise to set headers.

```
# aws cloudformation describe-stacks --query "Stacks[].[StackName,StackStatus,CreationTime]" --output table
-------------------------------------------------------------------------------------------
|                                     DescribeStacks                                      |
+-------------------------------+----------------------------+----------------------------+
|  tslw-website                 |  CREATE_COMPLETE           |  2017-03-23T15:25:11.082Z  |
|  tslw-backend                 |  UPDATE_COMPLETE           |  2017-02-10T13:13:24.004Z  |
+-------------------------------+----------------------------+----------------------------+
```

For more examples check out [awsinfo](TODO) and its source code as it uses `--query` and `--output` extensively to create a better user experience on top of the AWS CLI.