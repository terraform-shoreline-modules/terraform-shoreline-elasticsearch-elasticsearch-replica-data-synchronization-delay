#!/bin/bash

# Set the Elasticsearch index and replica shard name
INDEX=${INDEX_NAME}
REPLICA_SHARD=${REPLICA_SHARD_NAME}

# Check if the replica shard synchronization is stuck
REPLICA_STATUS=$(curl -s -XGET "http://localhost:9200/_cat/shards/$INDEX" | grep "$REPLICA_SHARD" | awk '{print $10}')
if [ "$REPLICA_STATUS" == "STARTED" ]; then
  echo "Replica shard synchronization is not stuck"
  exit 0
else
  # Replica shard synchronization is stuck
  echo "Replica shard synchronization is stuck"

  # Try to force a sync
  curl -XPOST "http://localhost:9200/$INDEX/_flush/synced"

  # Reset the replica shard
  curl -XPOST "http://localhost:9200/$INDEX/_settings" -H 'Content-Type: application/json' -d'{"index": {"blocks": {"read_only_allow_delete": null}}}'

  # Check if the replica shard synchronization is fixed
  REPLICA_STATUS=$(curl -s -XGET "http://localhost:9200/_cat/shards/$INDEX" | grep "$REPLICA_SHARD" | awk '{print $10}')
  if [ "$REPLICA_STATUS" == "STARTED" ]; then
    echo "Replica shard synchronization is fixed"
    exit 0
  else
    echo "Failed to fix replica shard synchronization"
    exit 1
  fi
fi