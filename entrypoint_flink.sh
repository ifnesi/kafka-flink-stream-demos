#!/usr/bin/env bash

# This script overrides the default docker-entrypoint.sh script included within
# the standard Flink image so that we can pre-create topics before they're
# referenced.
KAFKA_BIN_DIR=/opt/kafka/bin

# We only want to pre-create topics once, so do it during job manager startup
if [ "$1" = "jobmanager" ]; then
 	partitions=1
 	for topic in users shipments behavior_summary user_age user_name_age user_behavior
 	do
		partitions=$((partitions+1))
		echo "Pre-creating topic $topic"
		$KAFKA_BIN_DIR/kafka-topics.sh --bootstrap-server=$KAFKA_BOOTSTRAP_SERVER --create --topic=$topic --partitions=$partitions --replication-factor=1
 	done
fi

# Invoke the default entrypoint script now
/docker-entrypoint.sh "$@"
