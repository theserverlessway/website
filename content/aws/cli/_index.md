---
title: Introduction to the AWS CLI
weight: 1
---

The AWS CLI is the main tool to interact with AWS from your command line. All its commands are a direct representation of API calls you can make against the AWS API (there are a few additional commands for better UX).

The downside of the direct representation though is that its quite cumbersome to use as you have to remember long command and argument names. While this is ok for commands you call very often, it quickly becomes tiresome when you need to remember commands and arguments you use rarely.

Its better to think of the AWS CLI as a Shell SDK, the same way there are SDKs for any other programming language. Together with [other shell tools](TODO) it can become a very powerful and easy to use building block for your own tools.

This makes it possible to do nearly all of your work from your terminal without the need to go to the AWS console, making you a lot more productive and your infrastructure more automated.

Following is a brief introduction to some basics of the AWS CLI as well as more advanced options like the `--output` and especially the `--query` option. Those can be used very effictively to build more complex tooling.