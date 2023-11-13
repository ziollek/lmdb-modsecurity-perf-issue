FROM ubuntu:23.04

ARG NGINX_VERSION=1.22.0

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libtool autoconf build-essential libpcre3-dev zlib1g-dev libssl-dev libxml2-dev libgeoip-dev liblmdb-dev libyajl-dev libcurl4-openssl-dev pkgconf libxslt1-dev libgd-dev automake
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git curl wget gdb lsof strace systemtap
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nginx=${NGINX_VERSION}*

RUN mkdir -p /usr/local/src/workdir
WORKDIR "/usr/local/src/workdir"

# clone two versions of libmodsecurity one affected by issues second one with fixed issue
RUN git clone --branch v3.0.6 https://github.com/SpiderLabs/ModSecurity modsecurity-v3.0.6
RUN git clone --branch v3.0.7 https://github.com/SpiderLabs/ModSecurity modsecurity-v3.0.7

RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
RUN tar -xvzf nginx-${NGINX_VERSION}.tar.gz
RUN mv nginx-${NGINX_VERSION} nginx

# clone modsecurity-nginx module
RUN git clone https://github.com/SpiderLabs/ModSecurity-nginx

# build modsecurity affected by issue
WORKDIR "/usr/local/src/workdir/modsecurity-v3.0.6"
RUN git submodule init
RUN git submodule update
RUN sh build.sh
RUN ./configure --with-lmdb
RUN make

# build modsecurity where the issue is fixed
WORKDIR "/usr/local/src/workdir/modsecurity-v3.0.7"
RUN git submodule init
RUN git submodule update
RUN sh build.sh
RUN ./configure --with-lmdb
RUN make

# copy static configuration responsible for turning on modsecurity in nginx
COPY config/copy/load_mod_security.conf /etc/nginx/load_mod_security.conf
COPY config/copy/50-mod-http-modsecurity.conf /etc/nginx/modules-enabled/50-mod-http-modsecurity.conf