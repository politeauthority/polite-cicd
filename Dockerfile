FROM debian:stable-slim

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
RUN curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq

# Install kubectl
RUN curl -LOs "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
  rm -f kubectl

# Install kustomize
RUN curl -sL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.8.1/kustomize_v5.8.1_linux_amd64.tar.gz | \
  tar zxf - -C /usr/local/bin kustomize

# Install poetry and yamllint via pipx
RUN pipx install poetry && pipx install yamllint

# Install MinIO client
RUN curl -sSL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && \
  chmod +x /usr/local/bin/mc

# Install Taskfile
RUN sh -c "$(curl -s --location https://taskfile.dev/install.sh)" -- -d

# Add custom scripts (last to avoid busting cache on tool install layers)
ADD scripts/ /scripts
