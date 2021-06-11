# mikenye/youtube-dl

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/mikenye/docker-youtube-dl/Deploy%20to%20Docker%20Hub)](https://github.com/mikenye/docker-youtube-dl/actions?query=workflow%3A%22Deploy+to+Docker+Hub%22)
[![Docker Pulls](https://img.shields.io/docker/pulls/mikenye/youtube-dl.svg)](https://hub.docker.com/r/mikenye/youtube-dl)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/mikenye/youtube-dl/latest)](https://hub.docker.com/r/mikenye/youtube-dl)
[![Discord](https://img.shields.io/discord/734090820684349521)](https://discord.gg/sTf9uYF)

`yt-dl` - download videos many online video platforms

* Note: as of November 2020, this container will utilise [`yt-dlc`](https://github.com/blackjack4494/yt-dlc).
* Note: as of 23rd November 2020, this container has reverted to [`youtube-dl`](https://github.com/ytdl-org/youtube-dl) now that the repository has been re-instated.

## Table of Contents

* [mikenye/youtube-dl](#mikenyeyoutube-dl)
  * [Table of Contents](#table-of-contents)
  * [Multi Architecture Support](#multi-architecture-support)
  * [Quick Start](#quick-start)
  * [Running on Unraid](#running-on-unraid)
  * [Using a config file](#using-a-config-file)
  * [Authentication using `.netrc`](#authentication-using-netrc)
  * [Configuration Files](#configuration-files)
  * [Data Volumes](#data-volumes)
  * [Environment Variables](#environment-variables)
  * [Ports](#ports)
  * [Scheduled download of youtube subscriptions](#scheduled-download-of-youtube-subscriptions)
  * [Docker Image Update](#docker-image-update)
  * [Shell access](#shell-access)
  * [Support or Contact](#support-or-contact)

## Multi Architecture Support

This image should pull and run on the following architectures: `linux/amd64`, `linux/arm64/v8`, `linux/arm/v6`, `linux/arm/v7`, `linux/386`, `linux/ppc64le`, `linux/s390x`.

## Quick Start

**NOTE**: The docker command provided in this quick start is given as an example, and parameters should be adjusted to your needs.

It is suggested to configure an alias as follows (and place into your `.bash_aliases` file):

```shell
alias yt-dl='docker run \
                  --rm -i \
                  -e PGID=$(id -g) \
                  -e PUID=$(id -u) \
                  -v "$(pwd)":/workdir:rw \
                  mikenye/youtube-dl'
```

**HANDY HINT:** After updating your `.bash_aliases` file, run `source ~/.bash_aliases` to make your changes live!

When run (eg: `yt-dl <video_url>`), it will download the video to the current working directory, and take any command line arguments that the normal youtube-dl binary would.

## Running on Unraid

Unraid forum user Timmyx has written a fantastic guide to deploying this image on Unraid. The guide can be found here:

<https://forums.unraid.net/topic/100256-youtube-dl-strategy/>

## Using a config file

To prevent having to specify many command line arguments every time you run youtube-dl, you may wish to have an external configuation file.

In order for the docker container to use the configuration file, it must be mapped through to the container.

```shell
docker run \
    --rm -i \
    -e PGID=$(id -g) \
    -e PUID=$(id -u) \
    -v /path/to/downloaded/videos:/workdir:rw \
    -v /path/to/youtube-dl.conf:/etc/youtube-dl.conf:ro \
    mikenye/youtube-dl
```

Where:

* `/path/to/downloaded/videos` is where youtube-dl will download videos to (use `"$(pwd)"` to downloade to current working directory.
* `/path/to/youtube-dl.conf` is the path to your youtube-dl.conf file.

## Authentication using `.netrc`

If you want to download videos that require authentication (or your youtube subscriptions for example, see below), it is recommended to use a `.netrc` file.

You can create a file with the following syntax:

```text
machine youtube login USERNAME password PASSWORD
```

Where:

* `USERNAME` is replaced with your youtube account username
* `PASSWORD` is replaced with your youtube account password

You may need to disable some account security settings (such as '2-Step Verification' and 'Use your phone to sign in', so it is suggested to make a long, complex password (eg: 32 random characters).

This file can then be mapped through to the container as a `.netrc` file, eg:

```shell
docker run \
    --rm -i \
    -e PGID=$(id -g) \
    -e PUID=$(id -u) \
    -v /path/to/downloaded/videos:/workdir:rw \
    -v /path/to/youtube-dl.conf:/etc/youtube-dl.conf:ro \
    -v /path/to/netrc_file:/home/dockeruser/.netrc:ro
    mikenye/youtube-dl
```

## Configuration Files

| Container Path | Permissions | Description |
|----------------|-------------|-------------|
| `/config/youtube-dl.conf` | `ro` | If this file exists at container startup, it is symlinked to `/etc/youtube-dl.conf` at container startup. The `youtube-dl` process will look in this location for a configuration file by default. |
| `/config/.netrc` | `ro` | If this file exists at container startup, it is symlinked to `/home/dockeruser/.netrc` at container startup. The `youtube-dl` process will look in this location for a .netrc file (if `--netrc` is specified on the command line or via a configuration file). |
| `/config/.cache` | `rw` | If this directory exists at container startup, it is symlinked to `/home/dockeruser/.cache/youtube-dl` at container startup. The `youtube-dl` process automatically uses this path for caching. |

You can place any other configuration files within `/config`, and then specify them on the command line, eg: `--batch-file /config/batch-file.conf`.

## Data Volumes

There are no data volumes explicity set in the Dockerfile, however:

| Container Path | Permissions | Description |
|----------------|-------------|-------------|
| `/workdir` | rw | The `youtube-dl` process is executed with a working directory of `/workdir`. Thus, unless you override the output directory with the `--output` argument on the command line or via a configuration file, videos will end up in this directory.

## Environment Variables

To customize some properties of the container, the following environment variables can be passed via the `-e` parameter (one for each variable). This paramater has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable | Description | Recommended Setting |
|----------|-------------|---------------------|
| `PGID`     | The Group ID that the `youtube-dl` process will run as | `$(id -u)` for the current user's GID |
| `PUID`     | The User ID that the `youtube-dl` process will run as | `$(id -g)` for the current user's UID |
| `UMASK`    | Optional. Set's the umask for files created by `youtube-dl` | 
| `UPDATE_YOUTUBE_DL` | Set to any value and `youtube-dl -U` will be run on container start |

## Ports

No port mappings are required for this container.

## Scheduled download of youtube subscriptions

In order to perform a scheduled download of youtube subscriptions, it is recommended to use the following command to be executed via cron on a regular basis (eg: daily).

```shell
docker run \
    --rm
    -i
    --name youtube-dl-cron
    -e PGID=GID
    -e PUID=UID
    --cpus CPUS
    -v /path/to/netrc:/home/dockeruser/.netrc:ro
    -v /path/to/youtube/subscriptions:/workdir:rw
    -v /path/to/youtube-dl.conf:/etc/youtube-dl.conf:ro
    mikenye/youtube-dl \
    :ytsubscriptions \
    --dateafter now-5days \
    --download-archive /workdir/.youtube-dl-archive \
    --cookies /workdir/.youtube-dl-cookiejar \
    --netrc \
    --limit-rate 5000 2>> /path/to/logs/youtube-dl.err >> /path/to/logs/youtube-dl.log
```

Where:

* `GID`: a group ID to run as (if in a normal user's crontab, use `$(id -g)`
* `UID`: a user ID to run as (if in a normal user's crontab, use `$(id -u)`
* `CPUS`: the number of CPUs to constrain the docker container to. This may be required to prevent impacting system performance if transcoding takes place. If not, the `--cpus` argument can be completely omitted.
* `/path/to/netrc`: the path to the file containing your youtube credentials, see above.
* `/path/to/youtube/subscriptions`: the path where videos will be saved.
* `/path/to/youtube-dl.conf`: the path to your `youtube-dl.conf` file, where settings such as output file naming, quality, etc can be determined.
* `/path/to/logs/youtube-dl.err`: the path to the error log, if desired
* `/path/to/logs/youtube-dl.log`: the path to the application log, if desired

Notes:

* `--rm` is given so the container is destroyed when execution is finished. This will prevent your drive from slowly filling up with exited containers.
* `--name youtube-dl-cron` is given so that multiple instances are not started by cron. In the event the previous container is still running, docker will simply exit with an error that the container name is already taken.
* `--dateafter now-5days` is given to limit youtube-dl to only download recent videos. Feel free to adjust as required.
* `--limit-rate` is given to prevent impacting your internet connection. Feel free to adjust as required.

In the example above, a configuration file is used. This allows us to easily add commands to select a specific quality, and name the videos with a specific format. For example, to download the videos into a format recognised by Plex, you could use the following:

```shell
-v
--ignore-errors
--no-overwrites
--continue
--no-post-overwrites
--add-metadata
--write-thumbnail
--playlist-reverse
--write-description
--write-info-json
--write-annotations
--format "best[height<=?1080]"
--fixup fix
--output '/workdir/%(uploader)s/%(uploader)s - %(upload_date)s - %(title)s - %(id)s.%(ext)s'
```

The above example config file will:

* Ignore errors
* Will not overwrite existing videos
* Will continue downloading in the event a download is interrupted
* Will download metadata and embed into the resulting video, so that Plex will be able to display this information
* Will download oldest videos first, so videos can be sorted by "date added" in Plex
* Will download the best quality up to a maximum of 1080p (prevent 4K downloads)
* Will format videos with a separate folder for each uploader.

## Docker Image Update

If the system on which the container runs doesn't provide a way to easily update the Docker image (eg: watchtower), simply pull the latest version of the container:

```shell
docker pull mikenye/youtube-dl
```

## Shell access

To get shell access to a running container, execute the following command:

```shell
docker exec -ti CONTAINER sh
```

Where `CONTAINER` is the name of the running container.

To start a container with a shell (instead of `youtube-dl`), execute the following command:

```shell
docker run --rm -ti --entrypoint=/bin/sh mikenye/youtube-dl
```

## Support or Contact

Having troubles with the container or have questions? Please [create a new issue](https://github.com/mikenye/docker-youtube-dl/issues).
