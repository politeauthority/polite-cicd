# Polite-CICD 0.0.14
A Docker container for CICD operations.

## Docker Image
Hosted on Harbor at `harbor.squid-ink.us/politeauthority/polite-cicd:latest`
```bash
docker pull harbor.squid-ink.us/politeauthority/polite-cicd:latest
```

## Included Tooling
Running on Debian stable (slim) with the following tools:
- `git`, `jq`, `yq`, `gawk`
- `yamllint`
- `taskfile`
- Kubernetes / Containers
  - `kubectl`
  - `kustomize`
  - `docker` (CE + buildx + compose)
  - `helm`
  - `gh` (GitHub CLI)
- Network tools: `ping`, `traceroute`, `dnsutils`
- Python: `python3`, `pipx`, `poetry`
- MinIO client (`mc`)

## Taskfile

| Task | Description |
|---|---|
| `build-push` | Build `linux/amd64` image on M1, auto-increment patch version, push to Harbor with version tag and `:latest` |
| `docker-build` | Local build only (no push, no version bump) |
| `copy-to-build` | SCP Dockerfile, Taskfile, and scripts to `green-machine.ts` |
| `get-version` | Print current version from `VERSION` file |
| `dev-run` | Run the image as a background container named `polite-cicd` |
| `dev-exec` | Exec into the running `polite-cicd` container |

## Helpers
Deploy the image to a Kubernetes cluster with [Polite Deployment](helpers/polite-deployment.yaml)

## Updating Versions
Version is auto-incremented by `task build-push`. To manually update, edit:
- `README.md`
- `VERSION`
