#!/bin/bash
package_list="net-tools \
  curl \
  wget \
  rsync \
  unzip \
  zip \
  vim \
  jq \
  less \
  git \
  ca-certificates
"
apt-get update -y
apt-get install -y --no-install-recommends ${package_list[@]}
rm -rf /var/lib/lists

# hadolint
wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.10.0/hadolint-Linux-x86_64
chmod 755 /usr/local/bin/hadolint
