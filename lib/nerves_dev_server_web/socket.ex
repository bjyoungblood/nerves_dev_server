defmodule NervesDevServerWeb.Socket do
  use Phoenix.Socket

  channel "code", NervesDevServerWeb.Channels.CodeChannel
  channel "telemetry", NervesDevServerWeb.Channels.TelemetryChannel

  def connect(params, socket, connect_info) do
    IO.inspect(binding(), label: "connect")
    {:ok, assign(socket, :conn_id, System.unique_integer([:positive]))}
  end

  def id(socket) do
    "socket:#{socket.assigns.conn_id}"
  end
end
