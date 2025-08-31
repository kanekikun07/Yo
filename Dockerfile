FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y proxychains curl && \
    rm -rf /var/lib/apt/lists/*

# Copy a default proxychains config (will be overwritten at runtime)
COPY proxychains.conf /etc/proxychains.conf

# Set proxychains as entrypoint so all commands run through it
ENTRYPOINT ["proxychains", "-f", "/etc/proxychains.conf"]
