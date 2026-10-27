FROM debian:13-slim@sha256:62bd423aeee912639ca8ee681c2b762cb3e25137e0a92b20be455898a9f034ad
LABEL maintainer="Jurre van der Gaag - Terpstra <jurre@terpstra.tech>"

# renovate: datasource=github-tags depName=aws/aws-cli
ARG AWS_CLI_VERSION=2.38.6
# Set by buildx per platform: amd64 or arm64
ARG TARGETARCH

ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" LC_ALL="C.UTF-8" LANG="C.UTF-8"

RUN apt-get update && \
    apt-get install -y --no-install-recommends cron curl unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2 for the platform being built
RUN case "${TARGETARCH:-amd64}" in \
      amd64) arch=x86_64 ;; \
      arm64) arch=aarch64 ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${arch}-${AWS_CLI_VERSION}.zip" -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws && \
    aws --version

RUN mkdir -p /data /root/.aws

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
CMD ["start"]
