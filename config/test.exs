use Mix.Config

# Configure test environment
config :virtual_cluster,
  heartbeat_interval: 1_000, # Faster for tests
  heartbeat_timeout: 2_000

# ExUnit configuration
config :ex_unit,
  timeout: 30_000,
  capture_log: true
