FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y libav-tools ffmpeg rtmpdump mplayer mpv git-sh locales && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /home/dockeruser/youtube-dl && \
    git clone --progress https://github.com/rg3/youtube-dl.git /home/dockeruser/youtube-dl/ && \
    cd /home/dockeruser/youtube-dl && \
    python setup.py install && \
    locale-gen en_US.utf8 && \
    update-locale LANG=en_US.utf8 && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*
    
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8     

COPY init /init

RUN rm -rf /tmp/*
RUN rm -rf /var/tmp/*

# entrypoint
WORKDIR /home/dockeruser
ENTRYPOINT ["/init"]

