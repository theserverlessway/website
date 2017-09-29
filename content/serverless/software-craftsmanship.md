---
title: Serverless and Software Craftsmanship
weight: 200
---

With DevOps and now Serverless we've seen new trends that required developers to view their role in the development cycle in a new light. The distinction between operations and development have loosened. Developers need to consider the environment and infrastructure their applications run in a lot more and similarly operations teams do more of their work by developing automation software, similar to how developers work.

Oftentimes developers even create and help manage the infrastructure their applications run in through [CloudFormation](TODO) or other automation tooling.

The enormous number of existing and newly released cloud services by each provider require us to rethink our approach here though. The larger the number of services have become the more tools have come out to try to get this complexity under control and make things simpler. Through attempts of standardisation we've tried to create a more rigurious, a more engineered, approach to building infrastructure in this complex environment.

But what if this more structured, more standardised approach is actually hindering us from getting the most out of cloud serivces? With all the power those large numbers of services give us, why would we want to create layers on top that sometimes even stop us from using the cloud providers features?

## Serverless and Software Craftsmanship

Over the last years the tools and services cloud providers give us to create, develop, operate and debug our infrastructure have come a long way.

In the beginning, when cloud providers were mostly virtual server farms using high level tools to combine those virtual servers into more manageable units made sense. Over time though cloud providers integrated more and more of those features into their own offering, from AutoScalingGroups to ECS and RDS to Dynamo.

While that change is reflected in some of our tools, too often we still cling to the idea that we want to use large, powerfull, externally developed tools to manage our infrastructure. Because thats how it has been in the past.

But with the availability of these new kinds of services where the work we're doing is less in managing and understanding the whole complexity of every piece in our infrastructure, but in glueing them together this seems complex and not productive enough.

What if instead of trying to use large, complex, externally developed tools that are hard to adapt to all of our use cases we combine easy low level tools into flexible setups that let us manage our systems.

The AWS ClI for example is a powerful SDK that can be used to create simple yet powerful tooling that can be easily adapted to fit almost any use case when building on AWS. CloudFormation, while a bit verbose in its syntax and a bit overwhelming in its documentation, is a great service to do the complex task of managing our infrastructure.

But this approach means we have to rethink how we want to work with cloud services and what we use to build our systems.

We need to learn and understand the basic building blocks of our provider of choice so we can then use them to integrate any existing higher level service into our infrastructure. So we don't have to rely on large and complex tools for every use case. They certainly have their place, but only by choice, not out of necessity.

And those basic building blocks have never been easier to use and learn than today.

Every provider has their own set of tools, following are links to all guides for AWS tools and services you can find on this site.

* [***CloudFormation***](TODO) to create, deploy and modify your cloud infrastructure
* [***AWS CLI***](TODO) to interact with AWS APIs and build tools with
* [***IAM***](IAM) to manage access to your cloud resources
* [***CloudWatch***](CloudWatch) to monitor and operate your infrastructure and alert you when necessary