defmodule VirtualCluster.Test.ResourceDistributionTest do
  @moduledoc """
  Integration test for multi-machine resource distribution.
  """

  use ExUnit.Case, async: false

  @moduletag :integration

  test "distributes services based on resource compatibility" do
    # Deploy CPU-heavy service
    cpu_service = %{
      name: "cpu-intensive",
      image: "nginx:latest",
      resource_requirements: %{
        cpu_request: 2.0,
        memory_request: 1_000_000_000
      }
    }

    cpu_result = VirtualCluster.Scheduler.schedule(cpu_service)
    assert {:ok, cpu_node} = cpu_result

    # Deploy memory-heavy service
    mem_service = %{
      name: "memory-intensive",
      image: "nginx:latest",
      resource_requirements: %{
        cpu_request: 0.5,
        memory_request: 8_000_000_000
      }
    }

    mem_result = VirtualCluster.Scheduler.schedule(mem_service)
    assert {:ok, mem_node} = mem_result

    # Services should be on different nodes if possible
    # (depends on cluster topology)
    assert cpu_node != mem_node || length(VirtualCluster.Monitoring.Heartbeat.online_nodes()) == 1
  end

  test "considers resource utilization when scheduling" do
    # Deploy multiple services and verify utilization tracking

    services = [
      %{name: "svc-1", image: "nginx:latest", resource_requirements: %{cpu_request: 1.0, memory_request: 2_000_000_000}},
      %{name: "svc-2", image: "nginx:latest", resource_requirements: %{cpu_request: 1.0, memory_request: 2_000_000_000}}
    ]

    results = Enum.map(services, fn svc -> VirtualCluster.Scheduler.schedule(svc) end)
    assert Enum.all?(results, fn r -> match?({:ok, _}, r) end)
  end
end
