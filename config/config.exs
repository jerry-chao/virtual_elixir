# This file is responsible for configuring your application
# with its dependencies

use Mix.Config

config :virtual_cluster,
  cluster_name: System.get_env("CLUSTER_NAME", "default-cluster"),
  max_nodes: 10,
  min_nodes: 3,
  heartbeat_interval: 30_000, # 30 seconds
  heartbeat_timeout: 60_000,  # 60 seconds (2 missed heartbeats = offline)

config :libcluster,
  topologies: [
    vcluster: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: []
      ]
    ]
  ]

# Task execution and Docker
config :virtual_cluster,
  docker_host: System.get_env("DOCKER_HOST", "unix:///var/run/docker.sock"),
  rsync_retries: 3,
  rsync_timeout: 30_000

# Logging
config :logger,
  level: :info,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:request_id, :node, :service_id]

# Telemetry for observability
config :virtual_cluster,
  telemetry_prefix: [:virtual_cluster]

import_config "#{Mix.env()}.exs"
