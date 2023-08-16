ARG BUILD_FROM

FROM alpine/git:latest AS git

WORKDIR /git
RUN git clone --depth 1 https://github.com/acmesh-official/acme.sh.git

FROM $BUILD_FROM

RUN apk --update add openssl
COPY --from=git /git/acme.sh /opt/acme.sh
WORKDIR /opt/acme.sh
RUN ./acme.sh --install --home /acme.sh --config-home /data/acme.sh --nocron

WORKDIR /
ADD crontab.txt /crontab.txt
RUN /usr/bin/crontab /crontab.txt

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]