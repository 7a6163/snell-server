FROM debian:stable-slim AS build

# Use build arguments for better flexibility
ARG TARGETARCH
ARG SNELL_VERSION=v5.0.0b3

# Map Docker platform to Snell architecture
RUN apt-get update && \
    apt-get install -y curl unzip ca-certificates && \
    case "${TARGETARCH}" in \
        amd64) SNELL_ARCH="amd64" ;; \
        arm64) SNELL_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    echo "Building for architecture: ${TARGETARCH} -> ${SNELL_ARCH}" && \
    URL="https://dl.nssurge.com/snell/snell-server-${SNELL_VERSION}-linux-${SNELL_ARCH}.zip" && \
    echo "Downloading from: ${URL}" && \
    curl -fsSL -o snell-server.zip "${URL}" && \
    unzip snell-server.zip && \
    chmod +x snell-server && \
    ./snell-server --version || echo "Binary downloaded successfully" && \
    rm -f snell-server.zip && \
    apt-get remove -y curl unzip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Use debian:stable-slim for better compatibility (no additional packages needed)
FROM debian:stable-slim
COPY --from=build /snell-server /usr/local/bin/snell-server
ENTRYPOINT ["/usr/local/bin/snell-server"]
