FROM alpine:latest
RUN \
  addgroup -S pgpool &&\
  adduser -S pgpool -G pgpool &&\
  apk add --no-cache pgpool postgresql-client bash &&\
  mkdir /app &&\
  chown pgpool:pgpool /app

COPY pgpool.conf /etc/pgpool/
COPY --chmod=0755 docker-start.sh /usr/local/bin

USER pgpool

CMD ["docker-start.sh"]