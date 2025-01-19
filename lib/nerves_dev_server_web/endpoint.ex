defmodule NervesDevServerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :nerves_dev_server

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_nerves_dev_server_key",
    signing_salt: "DAjpuySP",
    same_site: "Lax"
  ]

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  socket "/", NervesDevServerWeb.Socket,
    websocket: [
      connect_info: [
        :peer_data,
        :trace_context_headers,
        :uri,
        :user_agent,
        :x_headers,
        session: @session_options
      ]
    ]

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug NervesDevServerWeb.Router
end
