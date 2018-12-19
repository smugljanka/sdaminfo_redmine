FROM alpine:3.8

USER root
ADD start.sh /

RUN apk update && \
    apk add --no-cache \
    py-pip \
    python && \
    pip install --upgrade --no-cache-dir \
    pip \
    awscli && \
    chmod +x /start.sh && \
    find /usr/local -depth \
       \( \
           \( -type d -a \( -name test -o -name tests \) \) \
           -o \
           \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
       \) -exec rm -rf '{}' + \
    && rm -rf /usr/src/python || true \
    && rm -rf /var/cache/apk/* || true

ENV KEY=,SECRET=,REGION=,BUCKET=,BUCKET_PATH=/,PARAMS=

VOLUME ["/backup"]

CMD ["/start.sh"]