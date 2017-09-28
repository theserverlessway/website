---
title: The Serverless Team
weight: 100
---

I've heard and taken part in many discussions about Serverless, its technical merits and why a specific infrastructure is or isn't Serverless.

Yes there are still servers, yes a container based infrastructure on ECS probably isn't a purists idea of Serverless and yes, jokes about restaurants being serverless can be funny when done in moderation (looking at you Paul Johnston).

But in the end a purely technical discussion, while being interesting, doesn't really go after the meat of the problem we're trying to solve. In the end what we want to do is build things faster, make them scalable in a way that we don't have to deal with it, have them fix themselves so we don't have to wake up at night and bring down costs. And all of that to build better products for our customers.

So what we're going after has more team and personal characteristics than purely technical ones. We want to:

* Limit control over infrastructure to the necessary minimum
* Limit responsibility for our infrastructure to the necessary minimum
* Escalate control and responsibility only when necessary
* Completely automate every step of development, release and operations to make changes easy and cheap

## An example

Lets take a look at ECS example from above. Typically you'd say it wasn't a good fit for a Serverless infrastructure. You have to provision your own EC2 instances and they have to be updated and maintained. All characteristics that typically aren't necessarily seen in a Serverless infrastructure.

But what if we decide to limit control and responsibility and increase automation? We could for example decide to only use Amazon Linux for our instances to make sure they are perfectly suited to being used for ECS. We could also decide to never update a Server once its running, but simply take them out of Service automatically every 12 hours and start from a new fully updated AMI after that. That AMI gets rebuilt (either every few hours or whenever we decide to) through AWS SSM so we know we can also rebuild it anytime if an important security update is released. That new AMI can even be fully integration tested to make sure it correctly starts and connects to an ECS cluster so we will never break this part of our infrastructure.

Up/Down scaling of those EC2 instances could be implemented through CloudWatch metrics and alarms together with a few Lambda functions. Through Applicaton Load Balancers we'll make sure that customer requests are only routed to available service containers in our cluster.

With additional alarms on our ELBs we can detect failing or problematic containers and possibly EC2 instances and take them out of rotation automatically.

As we turn off SSH access into all of our machines we set up awslogs agents on every machine to push log files into CloudWatch logs. This lets us debug any issues without having to actually go into any machine.

This system is in theory fully automated, heals itself and can be thoroughly tested before rollout (and have gradual rollout) to make sure we're not messing things up.

And of course all those CloudWatch Alarms should be connected to a notification system letting us know when something breaks so we can investigate afterwards step in to fix things if there is no automated mitigation.

## Wow this sounds complicated

And it is, though not as complicated as it sounds. The complexity simply moved from understanding one stack well (e.g. Rails app on multiple EC2 instances with a load balancer in front) to understanding and being able to manage all those cloud services and having the tools and processes in place to deal with them.

This change means as individual developers we have to adapt and become less reliant on others for our tools and deep understanding, but need to go there ourselves. We need to start seeing ourselves more as the craftspeople we are who build, maintain and share their own small set of tools than the engineers that rely on large tools and processes created by others.