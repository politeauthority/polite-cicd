#!/bin/bash
# Posgres Client Install
echo "Installing Postgres Client"
apt update
apt install -y curl ca-certificates gnupg
curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
apt install -y

apt install -y postgresql postgresql-contrib
echo "Successfully installed Postgres Client"
