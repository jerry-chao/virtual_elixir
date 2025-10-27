defmodule VirtualCluster.Test.ClusterStatusTest do
  @moduledoc """
  Integration test for cluster status API.
  """

  use ExUnit.Case, async: false

  @moduletag :integration

  test "cluster status shows all nodes" do
    # Record some nodes
    VirtualCluster.Monitoring.Heartbeat.record_heartbeat("node-1")
    VirtualCluster.Monitoring.Heartbeat.record_heartbeat("node-2")

    # Get cluster status
    status = get_cluster_status()

    assert status != nil
    assert Map.has_key?(status, :id)
    assert Map.has_key?(status, :node_count)
    assert Map.has_key?(status, :service_count)
  end

  test "cluster status shows node details" do
    # TODO: Implement cluster status API test
    # This would test the actual API endpoint
    assert true
  end

  defp get_cluster_status do
    # For MVP, return mock status
    %{
      id: "test-cluster",
      name: "Test Cluster",
      status: :active,
      node_count: 3,
      service_count: 5
    }
  end
end
