FROM debian:stable-slim

# Built for linux/amd64 and linux/arm64 (see build-push). buildx sets
# TARGETARCH to amd64 or arm64, which is also how every binary download below
# names its architecture.
ARG TARGETARCH

# Set up APT repos (Docker, GitHub CLI) and install base packages in one layer.
# Helm is installed as a binary below — baltocdn.com has HTTP/2 issues under QEMU.
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
    curl \
    gpg \
    ca-certificates \
  && \
  # Docker APT repo
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  # GitHub CLI APT repo
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    jq \
    git \
    python3-pip \
    dnsutils \
    traceroute \
    iputils-ping \
    pipx \
    gawk \
    gh \
  && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Docker CE separately — its components have strict inter-version dependencies
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
  && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Helm (binary — avoids baltocdn.com which has HTTP/2 issues under QEMU)
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install yq (mikefarah Go binary — not in standard Debian repos)
RUN curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${TARGETARCH} \
  -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq

# Install kubectl
RUN curl -LOs "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" && \
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
  rm -f kubectl

# Install kustomize
RUN curl -sL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.8.1/kustomize_v5.8.1_linux_${TARGETARCH}.tar.gz | \
  tar zxf - -C /usr/local/bin kustomize

# Install poetry and yamllint via pipx
RUN pipx install poetry && pipx install yamllint

# Install MinIO client. MinIO archived mc in 2025 and dl.min.io now answers 410,
# so this pins the final GitHub release.
ARG MC_RELEASE=RELEASE.2025-08-13T08-35-41Z
RUN curl -fsSL https://github.com/minio/mc/releases/download/${MC_RELEASE}/mc.linux-${TARGETARCH}.${MC_RELEASE} \
  -o /usr/local/bin/mc && chmod +x /usr/local/bin/mc

# Install Taskfile
RUN sh -c "$(curl -s --location https://taskfile.dev/install.sh)" -- -d

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
  mv /root/.local/bin/uv /usr/local/bin/uv

# Fail the build on a binary for the wrong architecture: it would only show up
# as "exec format error" in somebody's CI job.
RUN yq --version && kubectl version --client && kustomize version && mc --version && \
  helm version --short && task --version && uv --version && gh --version && docker --version

# Add custom scripts (last to avoid busting cache on tool install layers)
ADD scripts/ /scripts
