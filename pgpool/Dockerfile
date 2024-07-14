FROM alpine:latest
RUN \
  addgroup -S pgpool &&\
  adduser -S pgpool -G pgpool &&\
  apk add --no-cache pgpool postgresql-client bash &&\
  mkdir /app &&\
  chown pgpool:pgpool /app

COPY --chmod=0755 docker-start.sh /usr/local/bin

ENV PGPASSFILE=/app/.pgpass
ENV PGPORT=5432
ENV PGHOST=localhost

USER pgpool

CMD ["docker-start.sh"]