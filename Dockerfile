FROM python:3-slim

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=en_US:en

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    # Packages only required during build
    TEMP_PACKAGES+=(git) && \
    TEMP_PACKAGES+=(make) && \
    TEMP_PACKAGES+=(pandoc) && \
    # Packages kept in the image
    KEPT_PACKAGES+=(bash) && \
    KEPT_PACKAGES+=(ca-certificates) && \
    KEPT_PACKAGES+=(ffmpeg) && \
    KEPT_PACKAGES+=(locales) && \
    KEPT_PACKAGES+=(locales-all) && \
    KEPT_PACKAGES+=(mplayer) && \
    KEPT_PACKAGES+=(mpv) && \
    KEPT_PACKAGES+=(rtmpdump) && \
    KEPT_PACKAGES+=(zip) && \
    KEPT_PACKAGES+=(atomicparsley) && \
    # Install packages
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        ${KEPT_PACKAGES[@]} \
        ${TEMP_PACKAGES[@]} \
        && \
    git config --global advice.detachedHead false && \
    # Install ytdl
    git clone https://github.com/ytdl-org/youtube-dl.git /src/youtube-dl && \
    pushd /src/youtube-dl && \
    BRANCH_YTDL=$(git tag --sort='creatordate' | tail -1) && \
    git checkout "${BRANCH_YTDL}" && \
    make && \
    make install && \
    popd && \
    # Create /config directory
    mkdir -p /config && \
    # Clean-up.
    apt-get remove -y ${TEMP_PACKAGES[@]} && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /src && \
    youtube-dl --version > /CONTAINER_VERSION

# # Copy init script, set workdir & entrypoint
COPY init /init
WORKDIR /workdir
ENTRYPOINT ["/init"]
