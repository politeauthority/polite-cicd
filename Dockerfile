FROM debian:stable-slim

RUN apt-get update && apt-get install \
  --no-install-recommends -y \
  curl wget gpg ca-certificates

# Helm Signing
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor |tee /usr/share/keyrings/helm.gpg > /dev/null
RUN apt-get update
RUN apt-get install curl gpg -y
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor |tee /usr/share/keyrings/helm.gpg > /dev/null
RUN apt-get install apt-transport-https jq git wget ca-certificates --yes

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install kustomize
RUN wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.8.5/kustomize_v3.8.5_linux_amd64.tar.gz && \
  tar zxf kustomize_v3.8.5_linux_amd64.tar.gz && \
  mv  kustomize /usr/local/bin

# Install Helm
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

# Download kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# Install pip
RUN apt install python3-pip -y

# Install yamllint
RUN pip3 install yamllint --break-system-packages

# Prep docker
RUN mkdir -m 0755 -p /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install MinIO
 RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o /minio-binaries/mc && chmod +x /minio-binaries/mc && mv /minio-binaries/mc /bin && rm -rf /minio-binaries

# Run Generic Installs
RUN apt-get update && apt-get install -y --no-install-recommends \
  apt-transport-https jq git python3-pip yq helm \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin \
  postgresql-client pipx default-mysql-client

RUN pipx ensurepath && pipx install poetry

RUN pipx ensurepath && pipx install poetry

# Install kubectl
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install kustomize
RUN wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.8.5/kustomize_v3.8.5_linux_amd64.tar.gz && \
  tar zxf kustomize_v3.8.5_linux_amd64.tar.gz && \
  mv  kustomize /usr/local/bin && rm kustomize_v3.8.5_linux_amd64.tar.gz

# Install yamllint
RUN pip3 install yamllint --break-system-packages

# Install Taskfile
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d

ADD ./scripts/q-postgres /bin

# Install debug tools
RUN apt-get install -y --no-install-recommends dnsutils traceroute iputils-ping && rm -rf /var/lib/apt/lists/*

