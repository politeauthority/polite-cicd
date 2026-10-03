# Polite-CICD 0.0.14
A Docker container for CICD operations.

## Docker Image
Hosted on Harbor at `harbor.alix.lol/politeauthority/polite-cicd:latest`, built for `linux/amd64` and `linux/arm64`.
```bash
docker pull harbor.alix.lol/politeauthority/polite-cicd:latest
```

## Variants

| Image | Dockerfile | For |
|---|---|---|
| `polite-cicd` | `Dockerfile` | The shared CI image. `stocky`, `stocky-traders`, `private-ops`. |
| `polite-cicd-node` | `Dockerfile.node` | `polite-cicd` + Node 22. `stocky-frontend` only. |

`polite-cicd-node` is built `FROM` the published `polite-cicd` of the same
version, so the two never drift and `polite-cicd-node:0.0.16` is exactly
`polite-cicd:0.0.16` plus Node.

It exists as a separate image on purpose. `stocky-frontend` is the only repo
that needs Node, and its CI was losing 38-59s per job to `actions/setup-node` —
a container job has no tool cache, so the Node distribution is re-downloaded
every run. Adding Node to the shared image would fix that by charging `stocky`
and `stocky-traders` ~130MB of pull they never use, on every job.

Build order matters: `build-push` first (it is what `build-push-node` builds
`FROM`), then `build-push-node`.

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
- `uv`
- Network tools: `ping`, `traceroute`, `dnsutils`
- Python: `python3`, `pipx`, `poetry`
- MinIO client (`mc`)

## Taskfile

| Task | Description |
|---|---|
| `build-push` | Build `linux/amd64` image on M1, auto-increment patch version, push to Harbor with version tag and `:latest` |
| `build-push-node` | Build and push `polite-cicd-node` (the Node 22 variant) at the current `VERSION`. Run **after** `build-push`. |
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
