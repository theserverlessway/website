---
title: ChangeSets
weight: 3
---

ChangeSets are the main way how you should deploy to CloudFormation. They allow you to see exactly what steps CloudFormation would take once you deploy the ChangeSet, so you can find any problems beforehand.

To create a ChangeSet you simply upload a new version of your CloudFormation template. CloudFormation will calculate all the changes which can then be viewed by you. Depending on the complexity of a ChangeSet calculating the necessary actions might take a few seconds. If you're looking for a great client to help you with creating and deploying ChangeSets check out [Formica](/tools/formica). Other tools like the AWSCli support this as well.

The default description for ChangeSets is complicated and for typical daily use unimportant. If you want to see it in all its details check out the [Changed documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_Change.html), bhe main aspects you should focus on (and which Formica as well as AWSInfo provide to you by default) are:

* Logical and Physical ID of the resource to be changed
* Action taken on the resource, e.g. Add, Remove or Modify
* The properties that have changed
* If those properties were changed directly, or because another resource they depend on have changed

With that information you can get a good understanding of what is about to happen if you deploy the ChangeSet.

In the following example I've used [AWSIinfo](/tools/awsinfo) to show me all the details of a particular ChangeSet. In this case I've used the stack we deployed before and changed the `WebBucketName` parameter as well as set the DevBucketName. For each Bucket I've also changed the `IndexDocument` parameter to `index.htmls` to trigger a change.

```
# awsinfo cfn change-set tslw -- tslw
Selected Stack tslw-production
Selected CHANGE-SET tslw-production-change-set
-----------------------------------------------------------------------------------------------------------------------------------------
|                                                           DescribeChangeSet                                                           |
+---------------------+------------------------------------+----------------------+-------------------+---------------------------------+
|       1.Stack       |          2.ChangeSetName           |      3.Status        |   4.Executable    |           5.CreatedAt           |
+---------------------+------------------------------------+----------------------+-------------------+---------------------------------+
|  tslw-production    |  tslw-production-change-set        |  CREATE_COMPLETE     |  AVAILABLE        |  2017-10-05T12:06:42.918Z       |
+---------------------+------------------------------------+----------------------+-------------------+---------------------------------+
||                                                            6.Parameters                                                             ||
|+--------------------------------------------------------+----------------------------------------------------------------------------+|
||                      ParameterKey                      |                              ParameterValue                                ||
|+--------------------------------------------------------+----------------------------------------------------------------------------+|
||  CreateDevBucket                                       |  true                                                                      ||
||  WebBucketName                                         |  tslw-test-bucket-name                                                     ||
|+--------------------------------------------------------+----------------------------------------------------------------------------+|
||                                                              7.Changes                                                              ||
|+----------+--------------+------------------+----------------+-------------+------------------------------------+--------------------+|
|| 1.Action | 2.LogicalId  |     3.Type       | 4.Replacement  |  5.Scopes   |          6.StaticChanges           | 7.DynamicChanges   ||
|+----------+--------------+------------------+----------------+-------------+------------------------------------+--------------------+|
||  Modify  |  DevBucket   |  AWS::S3::Bucket |  True          |  Properties |  BucketName, WebsiteConfiguration  |                    ||
||  Modify  |  WebBucket   |  AWS::S3::Bucket |  True          |  Properties |  BucketName, WebsiteConfiguration  |  BucketName        ||
|+----------+--------------+------------------+----------------+-------------+------------------------------------+--------------------+|
```

One of the issues of ChangeSets though is that they don't include a full diff of the templates. They show which actions will be performed, but not enough detail to know exactly whats about to be changed, e.g. in the above example it says the `WebsiteConfiguration` changed, but not exactly which attribute in that config changed.

To solve this we need a diff between our deployed and local template. This is what [Formica](/tools/formica) provides with its `formica diff` command.

In the following example we get a full diff between the two templates, giving us more information about the changes we made to our templates.

```
# formica diff -s tslw-production
+---------------------------------------------------------------------------+-------------+-----------------------------+-----------------------+
|                                   Path                                    |    From     |             To              |      Change Type      |
+===========================================================================+=============+=============================+=======================+
| Resources > DevBucket > Properties > BucketName                           | Not Present | tslw-test-change-set-bucket | Dictionary Item Added |
+---------------------------------------------------------------------------+-------------+-----------------------------+-----------------------+
| Resources > DevBucket > Properties > WebsiteConfiguration > IndexDocument | index.html  | index.htmls                 | Values Changed        |
+---------------------------------------------------------------------------+-------------+-----------------------------+-----------------------+
| Resources > WebBucket > Properties > WebsiteConfiguration > IndexDocument | index.html  | index.htmls                 | Values Changed        |
+---------------------------------------------------------------------------+-------------+-----------------------------+-----------------------+
```

ChangeSet descriptions with AWSInfo (or Formica) as well as Formica diffs together will give you a complete overview on the changes you're about to make to your infrastructure. This makes it less likely for you to introduce bad configuration into your infrastructure and increases your productivity during development.
