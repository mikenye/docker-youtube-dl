# Builder container for pandoc, prerequisite for building youtube-dl
# (so build environment isn't in final container, to save space)
#FROM debian:stable-slim as builder_pandoc
#RUN apt-get update -y && \
#    apt-get install --no-install-recommends -y \
#            cabal-install \ 
#            zlib1g-dev \
#            wget \
#            ghc \
#            libc-dev && \
#    cabal update && \
#    cabal install --upgrade-dependencies --enable-per-component -j --force-reinstalls pandoc

# Builder container for youtube-dl
# (so build environment isn't in final container, to save space)
FROM debian:stable-slim as builder_ytdl
#COPY --from=builder_pandoc /root/.cabal /root/.cabal
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
            ffmpeg \
            rtmpdump \
            mplayer \
            mpv \
            python3 \
            git \
            make \
            zip \
            ca-certificates \
            pandoc && \
    git clone https://github.com/ytdl-org/youtube-dl.git && \
    cd /youtube-dl && \
    make -j && \
    make install
#     ln -s /root/.cabal/bin/pandoc /usr/local/bin/pandoc && \

# Final container
FROM debian:stable-slim as final
# Copy youtube-dl binary and manpage into container from builder container
COPY --from=builder_ytdl /usr/local/bin/youtube-dl /usr/local/bin/youtube-dl
COPY --from=builder_ytdl /usr/local/man/man1/youtube-dl.1 /usr/local/man/man1/youtube-dl.1
# Install & configure s6 overlay, then prerequisites for youtube-dl
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
            ffmpeg \
            rtmpdump \
            mplayer \
            mpv \
            python3 \
            bash \
            ca-certificates && \
    youtube-dl --version && \
    rm -rf rm -rf /var/lib/apt/lists/* /tmp/*

# Copy init script, set workdir & entrypoint
COPY init /init
WORKDIR /workdir
ENTRYPOINT ["/init"]
