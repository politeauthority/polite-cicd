#!/bin/bash
# Posgres Client Install
echo "Installing Postgres Client"
apt-get update
apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg 
curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null

apt-get install -y --no-install-recommends \
    postgresql-client-16
echo "Successfully installed Postgres Client"
