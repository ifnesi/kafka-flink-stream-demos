#!/bin/bash

# Build flink-sandbox/pydatagen docker images
docker build -t flink-sandbox . -f Dockerfile_flink
docker build -t pydatagen . -f Dockerfile_pydatagen

# Startup docker containers (1x job manager and 4x task managers)
docker-compose up --force-recreate --always-recreate-deps -V --scale taskmanager=5 -d

# Waiting services to be ready
echo ""
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://127.0.0.1:8081)" != "200" ]]
do
    echo "Waiting Apache Flink Job Manager to be ready..."
    sleep 5
done
echo "Apache Flink Job Manager is ready -> http://127.0.0.1:8081"
echo ""

while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://127.0.0.1:9021)" != "200" ]]
do
    echo "Waiting Confluent Control Center to be ready..."
    sleep 5
done
echo "Confluent Control Center is ready -> http://127.0.0.1:9021"
echo ""

echo "Demo environment is ready!"
echo ""