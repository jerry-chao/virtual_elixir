defmodule VirtualCluster.Test.FailureDetectionTest do
  @moduledoc """
  Integration test for failure detection.

  Tests that node failures are detected within the configured timeout.
  """

  use ExUnit.Case, async: false

  @moduletag :integration
  @timeout 60_000  # 60 seconds

  test "detects node failure within timeout" do
    node_id = "test-node-1"

    # Record initial heartbeat
    VirtualCluster.Monitoring.Heartbeat.record_heartbeat(node_id)

    # Verify node is online
    assert VirtualCluster.Monitoring.Heartbeat.online?(node_id) == true

    # Wait for timeout + buffer
    Process.sleep(@timeout + 5_000)

    # Verify node is marked as offline
    assert VirtualCluster.Monitoring.Heartbeat.online?(node_id) == false
  end

  test "gets list of online nodes" do
    # Record heartbeats for multiple nodes
    VirtualCluster.Monitoring.Heartbeat.record_heartbeat("node-1")
    VirtualCluster.Monitoring.Heartbeat.record_heartbeat("node-2")
    VirtualCluster.Monitoring.Heartbeat.record_heartbeat("node-3")

    online_nodes = VirtualCluster.Monitoring.Heartbeat.online_nodes()

    assert is_list(online_nodes)
    assert "node-1" in online_nodes
    assert "node-2" in online_nodes
    assert "node-3" in online_nodes
  end

  test "tracks node online status correctly" do
    node_id = "test-node-status"

    # Initially offline
    refute VirtualCluster.Monitoring.Heartbeat.online?(node_id)

    # Record heartbeat makes it online
    VirtualCluster.Monitoring.Heartbeat.record_heartbeat(node_id)
    assert VirtualCluster.Monitoring.Heartbeat.online?(node_id)
  end
end
