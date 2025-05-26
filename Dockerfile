FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Set build-time ARG
ARG ELASTIC_IP
ENV ELASTIC_IP=${ELASTIC_IP}
ARG ELASTIC_USER
ENV ELASTIC_USER=${ELASTIC_USER}
ARG ELASTIC_PASSWORD
ENV ELASTIC_PASSWORD=${ELASTIC_PASSWORD}

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    gnupg \
    wget \
    curl \
    unzip \
    python3 \
    python3-pip \
    lsb-release \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

# Add Plaso PPA and install Plaso
RUN add-apt-repository ppa:gift/stable -y && \
    apt-get update && \
    apt-get install -y plaso-tools && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directory
RUN mkdir -p /triage/data /triage/output

# Copy watcher script into container
COPY watcher.sh /usr/local/bin/watcher.sh
RUN chmod +x /usr/local/bin/watcher.sh

# Set entrypoint to script
ENTRYPOINT ["/usr/local/bin/watcher.sh"]