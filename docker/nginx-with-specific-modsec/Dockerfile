ARG BASE=nginx-with-modsec-base

FROM ${BASE}

ARG MODSEC_VERSION=3.0.7

WORKDIR "/usr/local/src/workdir/modsecurity-v${MODSEC_VERSION}"
RUN make install

WORKDIR "/usr/local/src/workdir/nginx"
RUN  ./configure --with-compat --with-openssl=/usr/include/openssl/ --add-dynamic-module=/usr/local/src/workdir/ModSecurity-nginx
RUN make modules
RUN cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules/

COPY config/copy/default-site.conf /etc/nginx/sites-available/default

WORKDIR "/tmp"

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]