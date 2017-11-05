# markmandel/gcloudshell
#
# Shell for Google Cloud Platform SDK
# Inspired by: https://registry.hub.docker.com/u/google/cloud-sdk/

FROM ubuntu
MAINTAINER Mark Mandel <mark.mandel@gmail.com>

# install google cloud sdk in root
WORKDIR /
RUN apt-get update && \
    apt-get install -y python zsh wget unzip less libapparmor1 libltdl7 nano

RUN wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip && unzip -q google-cloud-sdk.zip && rm google-cloud-sdk.zip
RUN /google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/root/.bashrc
ENV PATH /google-cloud-sdk/bin:$PATH

RUN gcloud components update app preview beta alpha kubectl --quiet

ENV PATH /go_appengine:$PATH

VOLUME ["/root/.config"]

WORKDIR /go

#App Engine port
EXPOSE 8080

ADD startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

