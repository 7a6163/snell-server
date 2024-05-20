FROM golang:1.18-alpine AS build

ENV SNELL_VERSION v4.0.1
ENV ARCH=${ARCH}

RUN apk add --no-cache curl zip

WORKDIR /app

RUN set -eux; \
    case "${ARCH}" in \
        amd64) SNELL_URL="https://dl.nssurge.com/snell/snell-server-${SNELL_VERSION}-linux-amd64.zip" ;; \
        i386) SNELL_URL="https://dl.nssurge.com/snell/snell-server-${SNELL_VERSION}-linux-i386.zip" ;; \
        aarch64) SNELL_URL="https://dl.nssurge.com/snell/snell-server-${SNELL_VERSION}-linux-aarch64.zip" ;; \
        armv7l) SNELL_URL="https://dl.nssurge.com/snell/snell-server-${SNELL_VERSION}-linux-armv7l.zip" ;; \
        *) echo "Unsupported architecture"; exit 1 ;; \
    esac; \
    curl -L -o snell-server.zip "$SNELL_URL"; \
    unzip snell-server.zip -d /app; \
    go build -o snell-server

FROM alpine:latest

ENV SNELL_VERSION v4.0.1
RUN apk add --no-cache tini

COPY --from=build /app/snell-server /usr/local/bin/snell-server

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/snell-server"]
