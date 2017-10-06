---
title: The Serverless Team
subtitle: Why Serverless is more than just infrastructure
weight: 100
---

I've heard and taken part in many discussions about Serverless, its technical merits and why a specific infrastructure is or isn't Serverless.

Yes there are still servers, yes a container based infrastructure on ECS probably isn't a purists idea of Serverless and yes, jokes about restaurants being serverless can be funny when done in moderation (looking at you Paul Johnston).

But in the end a purely technical discussion, while being interesting, doesn't really go after the meat of the problem we're trying to solve. In the end what we want to do is build things faster, make them scalable in a way that we don't have to deal with it, have them fix themselves so we don't have to wake up at night and bring down costs. And all of that to build better products for our customers.

So what we're going after has more team and personal characteristics than purely technical ones. We want to:

* Limit control and responsibility over infrastructure to the necessary minimum
* Escalate control and responsibility only when necessary
* Completely automate every step of development, release and operations to make changes easy and cheap

## Limit control and responsibility?

The limiting factor in most of our software efforts is developer time. We want to get the most out of it and try to be as productive as possible.

Through new higher level cloud services like Lambda, S3, RDS or Rekognition we can build larger infrastructure much quicker, but at the same time we give up lots of control over the specifics of each piece.

For example we can't tune our database in the same way we could if we ran it ourselves, but is that really necessary for the success of our product (and in some cases it might be).

You can think of control and responsibility here also as the need for customisation. Do you need pieces in your infrastructure to be customised in a way that can't be done with existing cloud services? Would it be possible to combine other services to achieve that goal while still pushing as much of your infrastructure into services?

And sometimes the answer is no and you have to run it yourself, but most of the time it should be perfectly fine to use and combine services.

## But what about lock-in?

Using high level cloud services (so anything above EC2 basically) leads to lock-in with a provider. There is no way around that really. The question is though how does this trade against being able to move faster and what scenarios does this not allow for in the future.

I've often heard the example of moving your whole infrastructure from one cloud provider to another, but have rarely seen that actually happening. Oftentimes specific workloads are moved to another provider because they have better high level services in a specific area (e.g. AI from Google Cloud). Which makes total sense as you want to use the best services available to you.

Multi-provider infrastructure is or will become a reality for many companies when they hit a large scale. The question is how to build your architecture in a way that allows you to move some pieces to another provider, while keeping others where they are because thats where they fit best.

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