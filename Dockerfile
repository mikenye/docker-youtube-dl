FROM debian:stable-slim

RUN set -x && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        bash \
        ca-certificates \
        ffmpeg \
        git \
        make \
        mplayer \
        mpv \
        pandoc \
        python3 \
        rtmpdump \
        zip \
        && \
    git clone https://github.com/ytdl-org/youtube-dl.git /src/youtube-dl && \
    cd /src/youtube-dl && \
    make && \
    make install && \
    apt-get remove -y \
        git \
        make \
        pandoc \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    youtube-dl --version && \
    rm -rf /var/lib/apt/lists/* /tmp/* /src

# Copy init script, set workdir & entrypoint
COPY init /init
WORKDIR /workdir
ENTRYPOINT ["/init"]
