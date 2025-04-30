defmodule NervesDevServer.MixProject do
  use Mix.Project

  @version "0.1.0"
  @github_repo "https://github.com/bjyoungblood/nerves_dev_server"

  def project do
    [
      app: :nerves_dev_server,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {NervesDevServer.Application, []},
      env: [{NervesDevServerWeb.Endpoint, []}],
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  #   Type `mix help deps` for examples and options.
  defp deps() do
    [
      {:alarmist, "~> 0.2", optional: true},
      {:bandit, "~> 1.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.37", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.2", optional: true},
      {:nerves_motd, "~> 0.1"},
      {:nerves_runtime, "~> 0.13"},
      {:phoenix, "~> 1.7.0"}
    ]
  end

  defp dialyzer() do
    ci_opts =
      if System.get_env("CI") do
        [plt_core_path: "_build/plts", plt_local_path: "_build/plts"]
      else
        []
      end

    [
      flags: [:unmatched_returns, :error_handling, :missing_return, :extra_return]
    ] ++ ci_opts
  end

  defp description() do
    "Development utilities for Nerves devices."
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @github_repo}
    ]
  end

  defp docs() do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @github_repo
    ]
  end
end
