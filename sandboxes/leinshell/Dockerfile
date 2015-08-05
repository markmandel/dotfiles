#markmandel/leinshell
#
# Shell for Clojure development, with Leiningen

FROM java:jdk
MAINTAINER Mark Mandel <mark.mandel@gmail.com>

RUN apt-get update && \
    apt-get install -y zsh openssh-server

#sshd setup - https://docs.docker.com/examples/running_ssh_service/
RUN mkdir /var/run/sshd
RUN echo 'root:pw' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22

#lein installation
ENV LEIN_ROOT=1
RUN cd /usr/local/bin/ && wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && chmod +x ./lein

RUN lein

ADD startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

RUN mkdir /project
WORKDIR /project

#port for web apps
EXPOSE 8080