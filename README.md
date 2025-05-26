# Triage2Elastic

**Triage2Elastic** is a Docker-based tool that automates the processing of triage collections from Windows, Linux, and macOS systems. It uses Plaso (`log2timeline.py`) to generate supertimelines from forensic artifacts and exports them directly to Elasticsearch using `psort.py`.

For collecting triage data, it is recommended to use KAPE (Windows only) or CyLR (which also supports Linux and macOS). 
Both tools support SFTP output.

---

## 🚀 Features

- Monitors a local directory for new triage collections
- Automatically runs `log2timeline` to parse forensic data
- Pushes timelines to Elasticsearch via `psort.py` 
- Runs as a Docker container

---

## 🐳 Usage

###  Clone the repo

```
git clone https://github.com/xlazarg/Triage2Elastic
cd Triage2Elastic
```

###  Build the Docker Image

```
docker build \
  --build-arg ELASTIC_IP=https://your-es-host:9200 \
  --build-arg ELASTIC_USER=elastic \
  --build-arg ELASTIC_PASSWORD=changeme \
  -t triage2elastic .
```

###  Start the container

```
docker run \
  -v /path/to/local/triage/data:/triage/data \
  -v /path/to/local/triage/output:/triage/output \
  triage2elastic
```
