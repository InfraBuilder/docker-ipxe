FROM alpine
MAINTAINER alexis@infrabuilder.com
RUN apk --update add dhcp tftp-hpa && rm -rf /var/cache/apk/*
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]