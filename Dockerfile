FROM --platform=$TARGETPLATFORM alpine:latest AS builder

RUN apk add --no-cache gcc make musl-dev linux-headers

WORKDIR /src
COPY . /src

RUN make -j$(nproc) BUILD_TLS=no MALLOC=libc

FROM --platform=$TARGETPLATFORM alpine:latest

LABEL maintainer="dev@hanzo.ai"
LABEL org.opencontainers.image.title="Hanzo Memory"
LABEL org.opencontainers.image.description="Redis-compatible in-memory store — Hanzo Memory"
LABEL org.opencontainers.image.vendor="Hanzo AI"
LABEL org.opencontainers.image.source="https://github.com/hanzoai/redis"

RUN addgroup -S memory && adduser -S memory -G memory

COPY --from=builder /src/src/redis-server    /usr/local/bin/redis-server
COPY --from=builder /src/src/redis-cli       /usr/local/bin/redis-cli
COPY --from=builder /src/src/redis-sentinel  /usr/local/bin/redis-sentinel
COPY --from=builder /src/src/redis-benchmark /usr/local/bin/redis-benchmark

RUN mkdir -p /data && chown memory:memory /data
VOLUME /data
WORKDIR /data

EXPOSE 6379

USER memory

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
    CMD redis-cli ping | grep -q PONG || exit 1

ENTRYPOINT ["redis-server"]
CMD ["--bind", "0.0.0.0", "--dir", "/data", "--maxmemory-policy", "allkeys-lru", "--protected-mode", "no"]
