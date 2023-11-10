terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "elasticsearch_replica_data_synchronization_delay" {
  source    = "./modules/elasticsearch_replica_data_synchronization_delay"

  providers = {
    shoreline = shoreline
  }
}