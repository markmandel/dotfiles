#
# Scudcloud Docker file.
# Credits: Heavily inspired by:https://github.com/jfrazelle/dockerfiles/blob/master/slack/Dockerfile
#

FROM ubuntu:14.04
MAINTAINER Mark Mandel <mark.mandel@gmail.com>

RUN apt-get update && \
    apt-get install -y software-properties-common

RUN apt-add-repository -y ppa:rael-gc/scudcloud && \
    apt-get update && \
    apt-get install -y scudcloud hunspell-en-us myspell-en-au myspell-en-gb \
    dbus-x11 python3-dbus libnotify-bin git

ENTRYPOINT ["/usr/bin/scudcloud"]
#ENTRYPOINT ["bash"]

