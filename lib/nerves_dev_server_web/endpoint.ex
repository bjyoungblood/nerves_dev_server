defmodule NervesDevServerWeb.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :nerves_dev_server

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  socket "/", NervesDevServerWeb.Socket, websocket: true

  plug Plug.MethodOverride
  plug Plug.Head

  plug NervesDevServerWeb.Router
end
