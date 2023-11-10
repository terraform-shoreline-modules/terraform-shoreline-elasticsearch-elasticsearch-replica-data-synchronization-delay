resource "shoreline_notebook" "elasticsearch_replica_data_synchronization_delay" {
  name       = "elasticsearch_replica_data_synchronization_delay"
  data       = file("${path.module}/data/elasticsearch_replica_data_synchronization_delay.json")
  depends_on = [shoreline_action.invoke_check_replica_sync,shoreline_action.invoke_update_elasticsearch_config]
}

resource "shoreline_file" "check_replica_sync" {
  name             = "check_replica_sync"
  input_file       = "${path.module}/data/check_replica_sync.sh"
  md5              = filemd5("${path.module}/data/check_replica_sync.sh")
  description      = "If the replica shard synchronization is stuck, try to force a sync or reset the replica shard."
  destination_path = "/tmp/check_replica_sync.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_elasticsearch_config" {
  name             = "update_elasticsearch_config"
  input_file       = "${path.module}/data/update_elasticsearch_config.sh"
  md5              = filemd5("${path.module}/data/update_elasticsearch_config.sh")
  description      = "Optimize Elasticsearch configuration: Elasticsearch configuration can be optimized for better performance. This includes settings like thread pools, heap size, and shard allocation. Optimizing these settings can help improve the speed of data synchronization."
  destination_path = "/tmp/update_elasticsearch_config.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_replica_sync" {
  name        = "invoke_check_replica_sync"
  description = "If the replica shard synchronization is stuck, try to force a sync or reset the replica shard."
  command     = "`chmod +x /tmp/check_replica_sync.sh && /tmp/check_replica_sync.sh`"
  params      = ["INDEX_NAME","REPLICA_SHARD_NAME"]
  file_deps   = ["check_replica_sync"]
  enabled     = true
  depends_on  = [shoreline_file.check_replica_sync]
}

resource "shoreline_action" "invoke_update_elasticsearch_config" {
  name        = "invoke_update_elasticsearch_config"
  description = "Optimize Elasticsearch configuration: Elasticsearch configuration can be optimized for better performance. This includes settings like thread pools, heap size, and shard allocation. Optimizing these settings can help improve the speed of data synchronization."
  command     = "`chmod +x /tmp/update_elasticsearch_config.sh && /tmp/update_elasticsearch_config.sh`"
  params      = ["DESIRED_SHARD_ALLOCATION","DESIRED_THREAD_POOL_SIZE","DESIRED_HEAP_SIZE","PATH_TO_ELASTICSEARCH_CONFIG_FILE"]
  file_deps   = ["update_elasticsearch_config"]
  enabled     = true
  depends_on  = [shoreline_file.update_elasticsearch_config]
}

