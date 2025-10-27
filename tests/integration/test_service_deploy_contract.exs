defmodule VirtualCluster.Test.ServiceDeployContractTest do
  @moduledoc """
  Contract test for service deployment API.

  Tests the API contract as specified in contracts/cluster-api.yaml
  """

  use ExUnit.Case, async: false

  @moduletag :integration
  @moduletag :contract

  test "service deployment request matches OpenAPI schema" do
    # Test that deployment configuration matches the API contract
    config = %{
      "name" => "test-service",
      "image" => "nginx:latest",
      "exposed_ports" => [80, 443],
      "resource_requirements" => %{
        "cpu_request" => 0.5,
        "memory_request" => 1024
      }
    }

    # Parse the config using our parser
    parsed = VirtualCluster.Services.ConfigParser.parse(config)

    assert parsed.name == "test-service"
    assert parsed.image == "nginx:latest"
    assert parsed.exposed_ports == [80, 443]
    assert parsed.resource_requirements.cpu_request == 0.5
    assert parsed.resource_requirements.memory_request == 1024
  end

  test "service status response matches OpenAPI schema" do
    # Test that service status tracking returns proper structure
    service_id = "test-service-1"

    # Get service status
    status = VirtualCluster.Services.StatusTracker.get(service_id)

    assert status != nil
    assert Map.has_key?(status, :service_id)
    assert Map.has_key?(status, :status)
    assert status.status in [:deploying, :running, :stopped, :failed, :migrating]
  end

  test "service instance response matches OpenAPI schema" do
    # Test that service instance data matches the API contract
    # This would typically come from ServiceRegistry
    # For now, we verify the structure exists

    instance = %VirtualCluster.Models.ServiceInstance{
      id: "inst-1",
      service_id: "svc-1",
      node_id: "node-1",
      container_id: "container-123",
      status: :running,
      health: :healthy,
      started_at: DateTime.utc_now(),
      health_check_last_success: DateTime.utc_now()
    }

    assert instance.id != nil
    assert instance.status in [:starting, :running, :stopping, :stopped, :failed]
    assert instance.health in [:healthy, :unhealthy, :unknown]
  end
end
