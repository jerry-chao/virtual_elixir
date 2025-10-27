ExUnit.start()

defmodule TestHelper do
  @moduledoc """
  Helper functions for testing.
  """

  def mock_node_id(prefix \\ "test-node") do
    "#{prefix}-#{System.unique_integer([:positive])}"
  end

  def mock_service_id do
    "svc-#{System.unique_integer([:positive])}"
  end
end
