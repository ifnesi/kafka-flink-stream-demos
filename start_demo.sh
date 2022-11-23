#!/bin/bash

# Build flink-sandbox/pydatagen docker images
docker build -t flink-sandbox . -f Dockerfile_flink
docker build -t pydatagen . -f Dockerfile_pydatagen

# Startup docker containers (1x job manager and 4x task managers)
docker-compose up --force-recreate --always-recreate-deps -V --scale taskmanager=5 -d
