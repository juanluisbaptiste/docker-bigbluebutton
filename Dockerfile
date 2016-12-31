FROM ubuntu:14.04
MAINTAINER Juan Luis Baptiste juan.baptiste@gmail.com
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

RUN apt-get -y update && \
    apt-get install -y language-pack-en vim wget software-properties-common

#Add multiverse repo
#Add the BigBlueButton key
#Add the BigBlueButton repository URL and ensure the multiverse is enabled
#Add additional PPA's for libreoffice and libssl1.0.2
ADD deb/ffmpeg_2.3.3-1_amd64.deb .
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty multiverse" | tee -a /etc/apt/sources.list && \
    wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | apt-key add - && \
    echo "deb http://ubuntu.bigbluebutton.org/trusty-1-0/ bigbluebutton-trusty main" | tee /etc/apt/sources.list.d/bigbluebutton.list && \
    add-apt-repository ppa:libreoffice/libreoffice-4-4 && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    update-locale LANG=en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    apt-get install -y --allow-unauthenticated libvpx1 libvorbisenc2 libssl1.0.2 && \
    dpkg -i ffmpeg_2.3.3-1_amd64.deb

#Install ffmpeg
#RUN apt-get install -y build-essential git-core checkinstall yasm texi2html libvorbis-dev libx11-dev libxfixes-dev zlib1g-dev pkg-config

# Install Tomcat prior to bbb installation
RUN apt-get install -y tomcat7
# Replace init script, installed one is broken
ADD scripts/tomcat7 /etc/init.d/

#RUN bash -c "echo -e '#!/bin/bash\nexit 101' | install -m 755 /dev/stdin /usr/sbin/policy-rc.d"
#Install BigBlueButton
# #RUN apt-get update -y
RUN apt-get install -y --allow-unauthenticated bigbluebutton

#RUN mkdir /var/log/bigbluebutton && touch /var/log/bigbluebutton/bbb-1.0-recording-update.log
RUN apt-get install -y bbb-check haveged

#EXPOSE 80 9123 1935 5060 5060/udp 5066 5066/udp 5080 5080/udp 16384-32768/udp
EXPOSE 80 9123 1935

#Add helper script to start bbb
ADD scripts/*.sh /
RUN chmod 755 /bbb-start.sh
CMD ["/bbb-start.sh"]
