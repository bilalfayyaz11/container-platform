# Containerized Hadoop Data Processing Platform

## What This Does

This implementation runs a multi-container Apache Hadoop environment using Docker Compose. It includes HDFS for distributed storage, YARN for resource management, and MapReduce for distributed data processing.

The platform supports HDFS directory creation, file upload, distributed word count processing, HTTP log filtering, YARN job execution, and Hadoop cluster inspection through command-line tools and web interfaces.

This demonstrates how big data infrastructure components can be containerized for repeatable local validation, distributed systems learning, and data engineering workflow simulation.

## Architecture

    +-----------------------------+
    | Host Machine                 |
    | Docker Engine + Compose V2   |
    +-------------+---------------+
                  |
                  v
    +-----------------------------+
    | Hadoop Bridge Network        |
    | hadoop-network               |
    +-------------+---------------+
                  |
      +-----------+-----------+----------------+----------------+
      |                       |                |                |
      v                       v                v                v
+-------------+        +-------------+   +-------------+   +-------------+
| NameNode    |        | DataNode    |   | ResourceMgr |   | NodeManager |
| HDFS Master |        | HDFS Worker |   | YARN Master |   | YARN Worker |
| Port 9870   |        | Port 9864   |   | Port 8088   |   | Port 8042   |
+------+------+        +------+------+   +------+------+   +------+------+
       |                      |                 |                 |
       +----------+-----------+-----------------+-----------------+
                  |
                  v
        +---------------------+
        | MapReduce Runtime   |
        | WordCount, Grep, Pi |
        +----------+----------+
                   |
                   v
        +---------------------+
        | HDFS Data Storage   |
        | /user/input         |
        | /user/output        |
        +---------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Docker Compose V2
- Git
- curl
- tree
- At least 4 GB RAM
- At least 10 GB available disk space

## Setup & Installation

sudo apt update

sudo apt install -y docker.io docker-compose-v2 tree curl git

sudo systemctl enable --now docker

sudo usermod -aG docker $USER

newgrp docker

## How to Reproduce

Start the Hadoop environment:

docker compose up -d

Check container status:

docker compose ps

Verify HDFS health:

docker exec hadoop-namenode hdfs dfsadmin -report

Create HDFS directories:

docker exec hadoop-namenode hdfs dfs -mkdir -p /user/input

docker exec hadoop-namenode hdfs dfs -mkdir -p /user/output

Upload sample data:

docker exec hadoop-namenode hdfs dfs -put -f /tmp/sample.txt /user/input/sample.txt

List HDFS input files:

docker exec hadoop-namenode hdfs dfs -ls /user/input

Run MapReduce word count:

docker exec hadoop-namenode bash -c 'hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar wordcount /user/input /user/output/wordcount'

View word count results:

docker exec hadoop-namenode hdfs dfs -cat /user/output/wordcount/part-r-00000

Run Pi estimation:

docker exec hadoop-namenode bash -c 'hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 2 100'

Run HTTP status filtering:

docker exec hadoop-namenode bash -c 'hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar grep /user/input/access.log /user/output/successful-requests "200"'

Inspect HDFS capacity:

docker exec hadoop-namenode hdfs dfs -df -h

Inspect YARN nodes:

docker exec hadoop-namenode yarn node -list

Access web interfaces:

NameNode: http://localhost:9870

DataNode: http://localhost:9864

YARN ResourceManager: http://localhost:8088

NodeManager: http://localhost:8042

History Server: http://localhost:19888

Stop the environment:

docker compose down

## Tools Used

- Docker
- Docker Compose V2
- Apache Hadoop 3.3.6
- HDFS
- YARN
- MapReduce
- Bash
- Linux
- XML
- Git
- tree

## Key Skills Demonstrated

- Multi-container distributed system deployment
- Hadoop infrastructure configuration
- HDFS storage operations
- YARN resource management
- MapReduce job execution
- Docker Compose orchestration
- Container networking
- Big data workflow validation
- Distributed storage inspection
- Cluster troubleshooting
- Platform engineering for data infrastructure

## Real-World Use Case

Data engineering and platform teams use distributed storage and processing systems to handle datasets that are too large for a single machine. This implementation shows how Hadoop components can be containerized to create repeatable local environments for testing HDFS behavior, validating MapReduce workloads, and understanding the operational relationship between distributed storage, compute scheduling, and job execution.

## Lessons Learned

- Hadoop services require correct hostname-based communication between containers.
- HDFS and YARN must be configured together for MapReduce jobs to execute successfully.
- Docker Compose is useful for simulating distributed systems on a single machine.
- Small cloud machines need controlled YARN memory settings to avoid unstable job execution.
- Non-interactive container commands are more reliable for repeatable infrastructure validation.

## Troubleshooting Log

Issue:
Docker and Docker Compose were missing from the fresh Ubuntu environment.

Resolution:
Installed Docker Engine and Docker Compose V2 through apt.

Issue:
The original instructions used docker-compose with a hyphen.

Resolution:
Used the modern docker compose command supported by current Docker Compose V2.

Issue:
The Compose file included a top-level version field.

Resolution:
Removed the obsolete version field because modern Compose no longer requires it.

Issue:
The original workflow used an interactive container shell for many operations.

Resolution:
Converted HDFS and MapReduce steps into non-interactive docker exec commands for reliable copy-paste execution.

Issue:
Repeated MapReduce runs can fail if output directories already exist.

Resolution:
Added cleanup commands using hdfs dfs -rm -r -f before rerunning output-generating jobs.

Issue:
Small cloud instances can struggle with default YARN memory behavior.

Resolution:
Added YARN memory limits in yarn-site.xml to keep the environment stable.
