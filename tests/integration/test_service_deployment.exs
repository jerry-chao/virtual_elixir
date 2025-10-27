defmodule VirtualCluster.Test.ServiceDeploymentTest do
  @moduledoc """
  Integration test for service deployment functionality.
  """

  use ExUnit.Case, async: false

  @moduletag :integration
  @service_id "test-service-1"
  @image "nginx:latest"

  setup do
    # Cleanup any existing test data
    on_exit(fn ->
      # TODO: Cleanup test services if any
    end)

    :ok
  end

  test "can deploy a service to the cluster" do
    # Test that we can schedule and deploy a service
    service_config = %{
      name: @service_id,
      image: @image,
      resource_requirements: %{
        cpu_request: 0.1,
        memory_request: 1_000_000_000
      }
    }

    # Deploy the service
    result = VirtualCluster.Scheduler.schedule(service_config)

    assert {:ok, node_id} = result
    assert is_binary(node_id)

    # Verify service was registered
    # Note: This would need actual service registry implementation
    # service = VirtualCluster.ServiceRegistry.get(@service_id)
    # assert service != nil
    # assert service.image == @image
  end

  test "service deployment respects resource constraints" do
    # Test deployment with insufficient resources is rejected
    service_config = %{
      name: "large-service",
      image: @image,
      resource_requirements: %{
        cpu_request: 999.0,  # Impossible requirement
        memory_request: 999_999_999_999_999_999
      }
    }

    result = VirtualCluster.Scheduler.schedule(service_config)

    assert {:error, :insufficient_resources} = result
  end

  test "can deploy multiple services" do
    # Deploy first service
    config1 = %{name: "service-1", image: @image, resource_requirements: %{cpu_request: 0.1, memory_request: 500_000_000}}
    result1 = VirtualCluster.Scheduler.schedule(config1)
    assert {:ok, _node1} = result1

    # Deploy second service
    config2 = %{name: "service-2", image: @image, resource_requirements: %{cpu_request: 0.1, memory_request: 500_000_000}}
    result2 = VirtualCluster.Scheduler.schedule(config2)
    assert {:ok, _node2} = result2
  end
end
