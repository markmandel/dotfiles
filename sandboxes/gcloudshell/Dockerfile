# markmandel/gcloudshell
#
# Shell for Google Cloud Platform SDK + Go
# Inspired by: https://registry.hub.docker.com/u/google/cloud-sdk/

FROM markmandel/goshell
MAINTAINER Mark Mandel <mark.mandel@gmail.com>

#get the gb-gae plugin, so we can use it
RUN go get code.palmstonegames.com/gb-gae
RUN mv ./bin/* /usr/local/bin
RUN rm -rf /go

# install google cloud sdk in root
WORKDIR /
RUN apt-get update && \
    apt-get install -y wget unzip

RUN wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip
RUN /google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/root/.bashrc
ENV PATH /google-cloud-sdk/bin:$PATH

RUN gcloud components update app preview beta alpha --quiet

ENV APPENGINE_VERSION=1.9.24
RUN wget -O appengine.zip https://storage.googleapis.com/appengine-sdks/featured/go_appengine_sdk_linux_amd64-$APPENGINE_VERSION.zip && unzip -q appengine.zip && rm appengine.zip
ENV PATH /go_appengine:$PATH

VOLUME ["/root/.config"]

WORKDIR /go

CMD ["/bin/bash"]

