# Polite-CICD 0.0.13
A Docker container for CICD operations.

## Docker Image
Currently hosted on Docker Hub at `politeauthority/polite-cicd:latest`
```bash
docker pull politeauthority/polite-cicd:latest
```

## Included Tooling
Running on Debian 12 we include the following tools.
 - `git`
 - `jq`
 - `yq`
 - `yamllint`
 - `taskfile`
 - Virtualization
   - `kubectl`
   - `docker`
   - `helm`
 - Network Tools
  - `ping`
  - `traceroute`
 - python
   - python 3.11
   - pipx
   - poetry
 - MinIo
 - mysql-cli

## Helpers
Deploy the image to a Kubernetes cluster with [Polite Deployment][helpers/polite-deployment.yaml]


## Updating Versions
Update the following files when creating a new version.
 - `README.md`
 - `VERSION`
