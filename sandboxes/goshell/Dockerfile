#markmandel/goshell
#
# Shell for Go development

FROM golang:1.4.2
MAINTAINER Mark Mandel <mark.mandel@gmail.com>

RUN apt-get update && \
    apt-get install -y zsh

RUN go get github.com/constabulary/gb/...
RUN go get github.com/golang/lint/golint
RUN go get golang.org/x/tools/cmd/goimports

RUN mv ./bin/* /usr/local/bin

RUN rm -rf /go

#We use zsh from now on
ENV SHELL=/usr/bin/zsh