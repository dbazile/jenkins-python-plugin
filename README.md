# jenkins-python-plugin

## Using a custom runtime repository

By default, this plugin downloads precompiled Python runtimes from `s3://bazile.dev.jenkins-python-plugin.runtimes`.  For security reasons, you might want tighter control over where the Python runtimes are actually coming from.

This requires:

- AWS CLI
- Docker

### 1. In options, set custom repository

Change the _Runtime Repository_ to `some-s3-bucket-that-i-control`

### 2. Build and deploy custom runtimes

From the terminal, run:

```bash
./scripts/build-runtimes
./scripts/build-runtimes-macos  # if on MacOS
./scripts/deploy-runtimes my-custom-bucket
```

## Acknowledgements

This plugin used https://github.com/jenkinsci/golang-plugin as a reference.

For the Docker Python build workers, used https://github.com/docker-library/python as a starting point.
