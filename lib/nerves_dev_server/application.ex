defmodule NervesDevServer.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      NervesDevServer.CodeCompiler,
      NervesDevServerWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:nerves_dev_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NervesDevServer.PubSub},
      NervesDevServerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: NervesDevServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl Application
  def config_change(changed, _new, removed) do
    NervesDevServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
