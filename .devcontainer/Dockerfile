# syntax=docker/dockerfile:1

ARG BASE_IMAGE=ghcr.io/ethz-robotx/smb_ros2_workspace:main
FROM ${BASE_IMAGE}

ENV IS_DOCKER=true

# Create user account with proper setup
ARG USERNAME=robotx
ARG USER_UID=1000
ARG USER_GID=1000

# Create the user group if it doesn't exist
RUN if ! getent group "${USER_GID}" >/dev/null; then \
        groupadd -g "${USER_GID}" "${USERNAME}"; \
    fi

# Create the user account (useradd -m automatically creates home directory and shell files)
RUN useradd -m -s /bin/bash -u ${USER_UID} -g ${USER_GID} -G sudo ${USERNAME} \
    && echo ${USERNAME} ALL=\(ALL\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Suppress the sudo hint message
RUN touch /home/${USERNAME}/.sudo_as_admin_successful

# Set the default user
USER ${USERNAME}
ENV USER=${USERNAME}
WORKDIR /home/${USERNAME}
