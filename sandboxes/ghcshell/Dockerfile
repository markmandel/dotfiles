#markmandel/ghcshell
#
# Shell for Haskell development, with Cabal, etc

FROM haskell:7.8
MAINTAINER Mark Mandel <mark.mandel@gmail.com>

RUN apt-get update && \
    apt-get install -y zsh

RUN cabal update && cabal install hlint stylish-haskell ghc-mod

ADD startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

RUN mkdir /project
WORKDIR /project