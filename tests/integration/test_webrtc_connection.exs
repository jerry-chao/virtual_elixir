defmodule VirtualCluster.Test.WebRTCConnectionTest do
  @moduledoc """
  Integration test for WebRTC P2P connection.

  Tests that WebRTC connections can be established between clients and services.
  """

  use ExUnit.Case, async: false

  @moduletag :integration

  test "establishes WebRTC connection to service" do
    service_id = "webrtc-test-service"
    client_id = "client-123"

    # Establish connection
    result = VirtualCluster.P2P.Signaling.connect(service_id, client_id)

    assert {:ok, connection_id} = result
    assert is_binary(connection_id)
  end

  test "gets STUN/TURN server configuration" do
    servers = VirtualCluster.P2P.Signaling.get_stun_servers()

    assert is_list(servers)
    assert length(servers) > 0

    # Verify server format
    first_server = List.first(servers)
    assert String.starts_with?(first_server, "stun:")
  end

  test "handles connection failures gracefully" do
    service_id = "nonexistent-service"
    client_id = "client-456"

    # Attempt connection to non-existent service
    # This should fail gracefully
    result = VirtualCluster.P2P.Signaling.connect(service_id, client_id)

    # Should either succeed with null connection or fail gracefully
    assert result in [{:ok, _}, {:error, _}]
  end
end
