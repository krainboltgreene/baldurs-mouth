FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby CLI instead of the licensed Docker CLI
ARG USE_MOBY="true"
# [Option] Select CLI version
ARG CLI_VERSION="latest"

# Enable new "BUILDKIT" mode for Docker CLI
ENV DOCKER_BUILDKIT=1
ENV SHELL=/bin/zsh
ENV DEBIAN_FRONTEND=noninteractive

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

COPY library-scripts/*.sh /tmp/library-scripts/

RUN apt-get update
RUN apt-get install -y build-essential autoconf m4 software-properties-common inotify-tools libncurses5 \
  libwxgtk-webview3.0-gtk3-0v5 libglu1 libsctp1 libssh-dev xsltproc fop libodbc1 libxml2-utils libjs-jquery libjs-jquery-tablesorter

# Setting up some integral pieces
RUN /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true"
RUN /bin/bash /tmp/library-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" "${USE_MOBY}" "${CLI_VERSION}"
RUN /bin/bash /tmp/library-scripts/postgresql-debian.sh
RUN /bin/bash /tmp/library-scripts/erlang-debian.sh
RUN /bin/bash /tmp/library-scripts/elixir-debian.sh
RUN /bin/bash /tmp/library-scripts/node-debian.sh

# Clean up
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/etc/vscode-dev-containers/
COPY first-run-notice.txt /usr/local/etc/vscode-dev-containers/first-run-notice.txt

SHELL [ "/bin/zsh", "-c" ]

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to
# the Docker socket if "overrideCommand": false is set in devcontainer.json.
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
VOLUME [ "/var/lib/docker" ]
CMD [ "sleep", "infinity" ]
