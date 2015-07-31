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
    apt-get install -y dbus-x11 hunspell-en-us scudcloud

ADD startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

CMD /root/startup.sh



