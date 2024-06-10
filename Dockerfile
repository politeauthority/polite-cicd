FROM debian:stable-slim

# Install dependencies and Docker repository setup
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  curl \
  wget \
  gpg \
  ca-certificates \
  apt-transport-https \
  jq \
  git \
  python3-pip \
  yq \
  dnsutils \
  traceroute \
  iputils-ping \
  pipx

# Add Docker official GPG key and APT repository
RUN mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CE
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# Helm Signing and install
RUN curl -s https://baltocdn.com/helm/signing.asc | gpg --dearmor -o /usr/share/keyrings/helm.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" \
  | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
  apt-get update && \
  apt-get install -y helm

# Install kubectl
RUN curl -LOs "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
  rm -f kubectl

# Install kustomize
RUN wget --quiet https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.8.5/kustomize_v3.8.5_linux_amd64.tar.gz && \
  tar zxf kustomize_v3.8.5_linux_amd64.tar.gz && \
  mv kustomize /usr/local/bin/kustomize && \
  rm kustomize_v3.8.5_linux_amd64.tar.gz

# Install poetry
RUN pipx install poetry

# Install yamllint
RUN pip3 install yamllint --break-system-packages

# Install MinIO client
RUN curl -sSL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && \
  chmod +x /usr/local/bin/mc

# Install Taskfile
RUN sh -c "$(curl -s --location https://taskfile.dev/install.sh)" -- -d

# Add custom scripts
ADD ./scripts/q-postgres /bin

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure executable permissions for custom scripts
RUN chmod +x /bin/q-postgres
