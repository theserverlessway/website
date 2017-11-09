---
title: Docker for Tools
weight: 500
---

When working with dev tools you often have to install different dependencies or even language versions. Some of those tools might even depend on a specific operating system or other tool to be installed.

This can become tricky fast as handling all of the above cases can mean unnecessary time wasted on making all dependencies somehow work on the same machine. Docker is a great tool for handling this for any kind of dev tool as it isolates the environments the tools run in.

For tools like the AWSCLI or tools from the TSLW Tool Suite it also adds only minimal overhead to starting, making it a perfect companion in your daily development.

In this guide we'll give you a quick introduction on how to integrate and install tools in a way to make it easy for you to use on a daily basis. This guide will not go into details of building Docker containers, for that check out the [Docker getting started guide](https://docs.docker.com/get-started/). If you just want to use Docker for your dev tools it is really simple to get started with.

## Tools I use

There are two major ways I use to manage my development tools with Docker, whalebrew and bash aliases.

### Whalebrew

[Whalebrew](https://github.com/bfirsh/whalebrew) built by [@bfirsh](https://twitter.com/bfirsh) is a small layer on top of Docker that allows you to install any Docker container as an executable in your PATH.

Through docker labels you can set which environment variables should be pushed into the container, which volumes are accessible or which ports should be opened. Check out the [documentation](https://github.com/bfirsh/whalebrew#usage) for details.

There are a bunch of pre-built [whalebrew packages](https://github.com/whalebrew/whalebrew-packages), but I mostly use it to build and install my own (or reinstall from the whalebrew-packages repo reinstall script) to control how up to date the tools are.

Following is an example of installing a tool with Whalebrew that needs environment variables and the `~/.aws` folder:

```
○ → whalebrew install whalebrew/awscli
This package needs additional access to your system. It wants to:

* Read the environment variable AWS_ACCESS_KEY_ID
* Read the environment variable AWS_SECRET_ACCESS_KEY
* Read the environment variable AWS_SESSION_TOKEN
* Read the environment variable AWS_DEFAULT_REGION
* Read the environment variable AWS_DEFAULT_PROFILE
* Read the environment variable AWS_CONFIG_FILE
* Read and write to the file or directory "~/.aws"

Is this okay? (y/n) [y]:
```

After that aws is installed in your path:

```
○ → which aws
/usr/local/bin/aws
```

### Bash (or general shell) Aliases

While whalebrew is a great tool the downside is that I can't easily sync and backup the installed tools between different systems. I recently started to put [all my bash configuration and aliases](https://github.com/flomotlik/my-bash-it) into a separate repository used together with [bash-it](https://github.com/Bash-it/bash-it).

As part of this I created aliases to easily run any kind of container through an alias. All those aliases build on top of each other to be flexible. You can find those commands in the [docker customisations file](https://github.com/flomotlik/my-bash-it/blob/master/bash-it/customisations/docker.bash).

On top of that I then defined various aliases for different tools I'm using on a daily basis in an [apps config file](https://github.com/flomotlik/my-bash-it/blob/master/bash-it/customisations/apps.bash).

The upside of this is that I can easily sync this between different machines and back it up in case my machine goes down. The major downside to this though is that bash aliases aren't available by default in the shell used with make. This means I sometimes have to work around this.