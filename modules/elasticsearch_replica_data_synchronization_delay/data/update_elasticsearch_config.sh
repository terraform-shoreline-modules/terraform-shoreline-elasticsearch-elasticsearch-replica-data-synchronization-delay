#!/bin/bash

# Set variables
ES_CONFIG_FILE=${PATH_TO_ELASTICSEARCH_CONFIG_FILE}
THREAD_POOL_SIZE=${DESIRED_THREAD_POOL_SIZE}
HEAP_SIZE=${DESIRED_HEAP_SIZE}
SHARD_ALLOCATION=${DESIRED_SHARD_ALLOCATION}

# Update Elasticsearch configuration file
sed -i "s/thread_pool.size: .*/thread_pool.size: ${THREAD_POOL_SIZE}/" $ES_CONFIG_FILE
sed -i "s/-Xmx[0-9]+[MG]*/-Xmx${HEAP_SIZE}/" $ES_CONFIG_FILE
sed -i "s/-Xms[0-9]+[MG]*/-Xms${HEAP_SIZE}/" $ES_CONFIG_FILE
sed -i "s/cluster.routing.allocation.enable: .*/cluster.routing.allocation.enable: ${SHARD_ALLOCATION}/" $ES_CONFIG_FILE

# Restart Elasticsearch service
systemctl restart elasticsearch.service