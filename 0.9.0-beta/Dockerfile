FROM ubuntu:14.04
MAINTAINER Juan Luis Baptiste juan.baptiste@gmail.com
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

RUN apt-get -y update
RUN apt-get install -y language-pack-en vim wget
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales

# Add the BigBlueButton key
RUN wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | apt-key add -

# Add the BigBlueButton repository URL and ensure the multiverse is enabled
RUN echo "deb http://ubuntu.bigbluebutton.org/trusty-090/ bigbluebutton-trusty main" | tee /etc/apt/sources.list.d/bigbluebutton.list


#Add multiverse repo
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty multiverse" | tee -a /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y dist-upgrade

#Install ffmpeg
#RUN apt-get install -y build-essential git-core checkinstall yasm texi2html libvorbis-dev libx11-dev libxfixes-dev zlib1g-dev pkg-config
ADD deb/ffmpeg_2.3.3-1_amd64.deb .
RUN dpkg -i ffmpeg_2.3.3-1_amd64.deb

#Install Tomcat prior to bbb installation
#RUN apt-get install -y tomcat7

#Replace init script, installed one is broken
#ADD scripts/tomcat6 /etc/init.d/

#Install BigBlueButton
RUN apt-get update -y
#RUN apt-get install bbb-web
RUN apt-get install -y bigbluebutton bbb-demo

EXPOSE 80 9123 1935

#Add helper script to start bbb
ADD ../scripts/bbb-start.sh /usr/bin/

CMD ["/usr/bin/bbb-start.sh"]
