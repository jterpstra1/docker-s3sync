FROM debian:latest
LABEL Jurre van der Gaag - Terpstra <jurre@terpstra.tech>

ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cron curl unzip
# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

RUN mkdir -p /data && \ 
  mkdir -p /root/.aws

ADD run.sh /

RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
CMD ["start"]