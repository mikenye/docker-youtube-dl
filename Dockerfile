FROM alpine:3.9
RUN apk update && \
    apk add ffmpeg \
            rtmpdump \
            mplayer \
            mpv \
            python3 \
            gnupg && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl && \
    chmod a+rx /usr/local/bin/youtube-dl && \
    wget https://yt-dl.org/downloads/latest/youtube-dl.sig -O youtube-dl.sig && \
    gpg --receive-keys "7D33 D762 FD6C 3513 0481 347F DB4B 54CB A482 6A18" && \
    gpg --receive-keys "ED7F 5BF4 6B3B BED8 1C87 368E 2C39 3E0F 18A9 236D" && \
    gpg --verify youtube-dl.sig /usr/local/bin/youtube-dl && \
    apk del gnupg && \
    rm -rf /var/cache/apk/*

COPY init /init
WORKDIR /home/dockeruser
ENTRYPOINT ["/init"]

