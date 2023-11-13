FROM nginx-with-modsec-base

# following https://stackoverflow.com/questions/46032214/how-can-i-use-systemtapstap-in-the-centos-container-in-docker-for-mac
COPY scripts/download-kernel-headers.sh /tmp/download-kernel-headers.sh
RUN /bin/bash /tmp/download-kernel-headers.sh

RUN apt-get --yes install cmake git kmod flex bison rsync bc libelf-dev
RUN apt-get --yes install systemtap systemtap-sdt-dev

COPY scripts/install-kernel-headers.sh /tmp/install-kernel-headers.sh
RUN /bin/bash /tmp/install-kernel-headers.sh

RUN apt install -y bpfcc-tools