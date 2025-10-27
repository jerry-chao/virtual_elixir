defmodule VirtualCluster.MixProject do
  use Mix.Project

  def project do
    [
      app: :virtual_cluster,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixir_paths: elixir_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      preferred_cli_env: [
        check: :test
      ]
    ]
  end

  def application do
    [
      mod: {VirtualCluster.Application, []},
      extra_applications: [:logger, :runtime_tools, :crypto]
    ]
  end

  defp deps do
    [
      # Cluster coordination
      {:libcluster, "~> 3.3"},

      # JSON handling
      {:jason, "~> 1.4"},

      # HTTP client
      {:httpoison, "~> 2.2"},

      # Process monitoring
      {:observer_cli, "~> 1.7"},

      # Telemetry for observability
      {:telemetry, "~> 1.0"},

      # Testing
      {:ex_unit_notifier, "~> 1.0", only: :test},

      # Development
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "check": ["format --check-formatted", "credo", "dialyzer"]
    ]
  end

  defp elixir_paths(:test), do: ["lib", "test/support"]
  defp elixir_paths(_), do: ["lib"]
end
