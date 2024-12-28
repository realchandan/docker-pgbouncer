FROM alpine:3.21 AS builder
ARG VERSION=1.23.1

RUN apk add --no-cache curl gcc libc-dev libevent-dev make openssl-dev

RUN curl -sS -o /pgbouncer.tar.gz -L https://pgbouncer.github.io/downloads/files/$VERSION/pgbouncer-$VERSION.tar.gz && \
    tar -xzf /pgbouncer.tar.gz && \
    mv /pgbouncer-$VERSION /pgbouncer

RUN cd /pgbouncer && ./configure --prefix=/usr/local && make

FROM alpine:3.21

RUN apk add --no-cache libevent postgresql-client

COPY --from=builder /pgbouncer/pgbouncer /usr/bin

RUN mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer && chown -R postgres /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer

EXPOSE 6432
USER postgres

CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
