FROM alpine:latest
RUN apk add --no-cache pgpool

COPY pgpool.conf /etc/pgpool/
COPY --chmod=0755 docker-start.sh /usr/local/bin

USER guest

CMD ["docker-start.sh"]