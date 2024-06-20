# Polite-CICD 0.0.12
A Docker container for CICD operations.

## Docker Image
Currently hosted on Docker Hub at `politeauthority/polite-cicd:latest`
```bash
docker pull politeauthority/polite-cicd:latest
```

## Included Tooling
- `git`
- `JQ`
 - `kubectl`
 - `helm`
 - `docker`
 - taskfile
 - yamllint
 - ping
 - traceroute
 - helmlint
 - python
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
