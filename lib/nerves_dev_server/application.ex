defmodule NervesDevServer.Application do
  @moduledoc false

  use Application

  require Logger

  @impl Application
  def start(_type, _args) do
    token_secret = Application.get_env(:nerves_dev_server, :token_secret)

    if not token_secret_ok?(token_secret) do
      Logger.warning("""
      NervesDevServer does not have an auth token secret configured. This secret
      is used to sign and verify tokens for websocket connections.

      Add the following to your config.exs or runtime.exs file:

        config :nerves_dev_server, token_secret: "your_secret_here"

      To allow unauthenticated websocket connections, set the token_secret to false:

        config :nerves_dev_server, token_secret: false
      """)

      token_secret = :crypto.strong_rand_bytes(32)
      Application.put_env(:nerves_dev_server, :token_secret, Base.encode16(token_secret))
    end

    children = [
      NervesDevServer.CodeCompiler,
      {Phoenix.PubSub, name: NervesDevServer.PubSub},
      {NervesDevServerWeb.Endpoint, endpoint_config()}
    ]

    opts = [strategy: :one_for_one, name: NervesDevServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl Application
  def config_change(changed, _new, removed) do
    NervesDevServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp endpoint_config() do
    defaults = [
      adapter: Bandit.PhoenixAdapter,
      pubsub_server: NervesDevServer.PubSub,
      render_errors: [
        formats: [json: NervesDevServerWeb.ErrorJSON],
        layout: false
      ]
    ]

    overrides = Application.get_env(:nerves_dev_server, :endpoint, [])

    Keyword.merge(defaults, overrides)
  end

  defp token_secret_ok?(secret) do
    secret == false or (is_binary(secret) and byte_size(secret) >= 20)
  end
end
