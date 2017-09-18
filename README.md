# jenkins-python-plugin


## Building and using your own runtimes

By default, this plugin downloads precompiled Python runtimes from
`s3://bazile.jenkins.python`, an S3 bucket I created for this plugin.  In the
interest of better security, you might want control over where the Python
runtimes are actually coming from.

For that you can compile your own runtimes using the scripts in
[/runtimes](/runtimes) and use use the `Extract *.zip/*.tar.gz` installer and
specify a URL to a precompiled Python runtime tarball that your build agents
can reach.

### 1. Install required utilities

This requires:

- [AWS CLI](https://aws.amazon.com/cli/)
- [Docker](https://www.docker.com)

If not already on your machine, you'll have to install the required items.  If
you're not hosting the runtimes on S3 and are willing to manually deploy them
wherever, feel free to skip that step.

### 2. Build and deploy custom runtimes

From the terminal, run:

```bash
./scripts/build-all-linux
./scripts/build-all-macos  # if on MacOS
./scripts/deploy-to-s3 my-custom-bucket
```



## Reporting issues

Compiling Python from source (though in the writing of this plugin I've done
almost 1000 times over now) is something that is completely new to me.  If you
run into a problem, it's likely due to some misconfiguration in the runtime
compilers that I haven't bumped into yet in my testing.

> TL;DR, please file issues if you run into any.



## Known issues

### In Python 3, `venv` folder cannot be overwritten

If you're seeing this in your build logs...

```
+ python3 -m venv venv
Error: [Errno 13] Permission denied: '/path/to/jenkinshome/workspace/foo/venv/bin/activate'
```

...it's because of the immutability of the tool installation.  When `venv`
creates a virtual environment, it copies the files over, retaining whatever file
permissions it had originally.

The workaround for this is to either wipe away the workspace every build or test
for the existence of `./venv` first.



## Acknowledgements

This plugin used https://github.com/jenkinsci/golang-plugin as a reference.

For the Docker Python build workers, used https://github.com/docker-library/python as a starting point.
