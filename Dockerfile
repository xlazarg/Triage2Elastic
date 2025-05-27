FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG ELASTIC_INDEX=plaso
ENV ELASTIC_INDEX=${ELASTIC_INDEX}

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common gnupg wget curl unzip python3 python3-pip \
    openjdk-17-jre-headless lsb-release inotify-tools apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Install Plaso
RUN add-apt-repository ppa:gift/stable -y && \
    apt-get update && \
    apt-get install -y plaso-tools && \
    rm -rf /var/lib/apt/lists/*

# Install Logstash
RUN curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-8.x.list && \
    apt-get update && \
    apt-get install -y logstash && \
    rm -rf /var/lib/apt/lists/*

# Create folders
RUN mkdir -p /triage/data /triage/output

# Copy pipeline config and watcher
COPY pipeline.conf /etc/logstash/conf.d/pipeline.conf
COPY watcher.sh /usr/local/bin/watcher.sh
RUN chmod +x /usr/local/bin/watcher.sh

# Set entrypoint to script
ENTRYPOINT ["/usr/local/bin/watcher.sh"]