FROM ubuntu:16.04
MAINTAINER Juan Luis Baptiste juan.baptiste@gmail.com
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
ENV container docker
ENV init /lib/systemd/systemd

RUN apt-get -y update && \
    apt-get install -y language-pack-en vim wget systemd net-tools software-properties-common \
                       sudo apt-transport-https && \
    update-locale LANG=en_US.UTF-8 && \
    dpkg-reconfigure locales
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ xenial multiverse" | tee -a /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | apt-key add - && \
    echo "deb https://ubuntu.bigbluebutton.org/xenial-200/ bigbluebutton-xenial main" | tee /etc/apt/sources.list.d/bigbluebutton.list && \
    apt-get -y update
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \; && \
    systemctl set-default multi-user.target

#Install BigBlueButton
RUN apt-get install -y bigbluebutton
RUN apt-get install -y bbb-check haveged

#EXPOSE 80 9123 1935 5060 5060/udp 5066 5066/udp 5080 5080/udp 16384-32768/udp
EXPOSE 80 9123 1935

#Add helper script to start bbb
COPY scripts/*.sh /
RUN chmod 755 /*.sh && \
    echo "#!/bin/bash\nenv\n/bbb-start.sh" > /etc/rc.local && \
    chmod 755 /etc/rc.local

VOLUME [ "/sys/fs/cgroup" ]

ENTRYPOINT ["/lib/systemd/systemd"]
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
#CMD ["/run.sh"]
