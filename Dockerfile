FROM debian:stable-slim

# Install required packages and setup GPG keys in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl wget gpg ca-certificates apt-transport-https jq git python3-pip yq \
  helm docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  postgresql-client pipx dnsutils traceroute iputils-ping && \
  # Setup Helm signing key
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor -o /usr/share/keyrings/helm.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
  # Setup Docker GPG key
  mkdir -m 0755 -p /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list && \
  apt-get update && \
  # Install kubectl
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
  # Install kustomize
  wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.8.5/kustomize_v3.8.5_linux_amd64.tar.gz && \
  tar zxf kustomize_v3.8.5_linux_amd64.tar.gz && \
  mv kustomize /usr/local/bin && \
  rm kustomize_v3.8.5_linux_amd64.tar.gz && \
  # Install yamllint
  pip3 install yamllint --break-system-packages && \
  # Install Taskfile
  sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d && \
  # Cleanup
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Add scripts
ADD ./scripts/q-postgres /bin

# Ensure pipx path
RUN pipx ensurepath
