FROM alpine:latest

RUN	apk --no-cache update  \
	&& apk add --no-cache \
    rsyslog \
    postfix \
    postfix-pcre \
    opendkim

RUN rm -fr /var/cache/apk/*

# Add entrypoint
COPY ./scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN if [ ! -e "/docker-entrypoint.d" ];then mkdir /docker-entrypoint.d;fi && chmod +x /docker-entrypoint.sh

# 25/tcp - postfix, 14999/tcp - opendkim
EXPOSE 25/tcp 14999/tcp
ENTRYPOINT /docker-entrypoint.sh