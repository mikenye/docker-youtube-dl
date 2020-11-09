FROM debian:stable-slim

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=en_US:en

RUN set -x && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        bash \
        ca-certificates \
        ffmpeg \
        git \
        locales \
        locales-all \
        make \
        mplayer \
        mpv \
        pandoc \
        python3 \
        rtmpdump \
        zip \
        && \
    git clone https://github.com/blackjack4494/yt-dlc.git /src/youtube-dlc && \
    cd /src/youtube-dlc && \
    BRANCH_YTLDC=$(git tag --sort='-creatordate' | head -1) && \
    git checkout "${BRANCH_YTLDC}" && \
    make && \
    make install && \
    apt-get remove -y \
        git \
        make \
        pandoc \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    youtube-dlc --version && \
    rm -rf /var/lib/apt/lists/* /tmp/* /src

# Copy init script, set workdir & entrypoint
COPY init /init
WORKDIR /workdir
ENTRYPOINT ["/init"]
