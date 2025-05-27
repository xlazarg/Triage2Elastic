# Triage2Elastic

**Triage2Elastic** is a Docker-based tool that automates the processing of triage collections from Windows, Linux, and macOS systems. It uses Plaso (`log2timeline.py`) to generate supertimelines from forensic artifacts and exports them directly to Elasticsearch.

For collecting triage data, it is recommended to use KAPE (Windows only) or CyLR (which also supports Linux and macOS). 

---

## 🔧 Features

- Monitors a local directory for new triage collections
- Automatically runs `log2timeline` to parse forensic data
- Pushes timelines to Elasticsearch
- Runs as a Docker container

---

## 🐳 Usage

###  Clone the repo

```
git clone https://github.com/xlazarg/Triage2Elastic.git
cd Triage2Elastic
```

###  Update the Logstash output configuration

```
    hosts => ["https://your-elasticsearch-ip:9200"]
    user => "elastic"
    password => "changeme"
```

###  Build the Docker Image

```
docker build -t triage2elastic .
```

###  Start the container

```
docker run -v /local/triage/data:/triage/data -v /local/triage/output:/triage/output triage2elastic
```

###  Move the triage collection to the local input folder

💡 This folder can also be specified as an SFTP output destination in KAPE or CyLR.

```
mv victim1 /local/triage/data
```