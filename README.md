# Polite-CICD 0.0.10
A Docker container for CICD operations.

## Docker Image
Currently hosted on Docker Hub at `politeauthority/polite-cicd:0.010`
```bash
docker pull politeauthority/polite-cicd:0.0.10
```

## Included Tooling
 - Git
 - JQ
 - Kubectl
 - Helm
 - Docker
 - taskfile
 - psql
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
