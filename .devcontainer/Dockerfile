# syntax=docker/dockerfile:1

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG VNC_RESOLUTION
ENV VNC_RESOLUTION=$VNC_RESOLUTION

ENV IS_DOCKER=true

# Create user account with proper setup
ARG USERNAME
ARG USER_UID=1000
ARG USER_GID=1000

# Create the user group if it doesn't exist
RUN if ! getent group ${USER_GID} >/dev/null; then \
        groupadd -g ${USER_GID} ${USERNAME}; \
    fi

# Create the user account (useradd -m automatically creates home directory and shell files)
RUN useradd -m -s /bin/bash -u ${USER_UID} -g ${USER_GID} -G sudo ${USERNAME} \
    && echo ${USERNAME} ALL=\(ALL\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Set the default user
USER ${USERNAME}
ENV USER=${USERNAME}
WORKDIR /home/${USERNAME}