# Dev Container
FROM debian:bookworm-20240812 AS devcontainer

ARG PYTHON_VERSION=3.12.4

WORKDIR /app
COPY ../ .

# aqua install
RUN <<EOF bash -ex
apt-get update -y
apt-get install -y --no-install-recommends wget ca-certificates
wget -q https://github.com/aquaproj/aqua/releases/download/v2.30.0/aqua_linux_amd64.tar.gz
rm -rf /usr/local/bin/aqua && tar -C /usr/local/bin/ -xzf aqua_linux_amd64.tar.gz
rm aqua_linux_amd64.tar.gz
rm -rf /var/lib/lists
EOF

# install packages and some tools.
# NOTE: rye is installed by aqua.
RUN aqua install

# build
# RUN <<EOF bash -ex
# PATH=$PATH":$(aqua root-dir)/bin"
# rye pin ${PYTHON_VERSION}
# rye sync
# rye build
# EOF


FROM python:3.12.4-slim-bullseye AS run
WORKDIR /app

ARG VERSION="0.1.0"
# FIXME: hogehoge
LABEL version="${VERSION}" \
      author="RyosukeDTomita" \
      docker_compose_build="docker buildx bake" \
      docker_build="docker buildx build . -t hogehoge" \
      docker_compose_run="docker compose run hogehoge" \
      docker_run="docker run hogehoge"

# install sudo
# RUN <<EOF bash -ex
# apt-get update -y
# apt-get install -y --no-install-recommends sudo
# rm -rf /var/lib/lists
# EOF

ARG USER_NAME="sigma"
ARG APP_NAME="sigma_super_app" # FIXME

# create execution user with sudo
RUN <<EOF bash -ex
echo 'Creating ${USER_NAME} group.'
addgroup ${USER_NAME}
echo 'Creating ${USER_NAME} user.'
adduser --ingroup ${USER_NAME} --gecos "sigma_super_app user" --shell /bin/bash --no-create-home --disabled-password ${USER_NAME}
echo 'using sudo'
usermod -aG sudo ${USER_NAME}
echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
EOF

COPY --from=devcontainer --chown=${USER_NAME}:${USER_NAME} ["/app/dist/${APP_NAME}-${VERSION}-py3-none-any.whl", "/app/dist/${APP_NAME}-${VERSION}-py3-none-any.whl"]

# install app
RUN python3 -m pip install /app/dist/${APP_NAME}-${VERSION}-py3-none-any.whl

USER ${USER_NAME}
#ENTRYPOINT ["sudo", "${APP_NAME}"]
ENTRYPOINT ["${APP_NAME}"]

