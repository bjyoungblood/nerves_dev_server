defmodule NervesDevServerWeb.Socket do
  @moduledoc false

  use Phoenix.Socket

  channel "code", NervesDevServerWeb.Channels.CodeChannel
  channel "telemetry", NervesDevServerWeb.Channels.TelemetryChannel

  @impl Phoenix.Socket
  def connect(_params, socket, _connect_info) do
    {:ok, assign(socket, :conn_id, System.unique_integer([:positive]))}
  end

  @impl Phoenix.Socket
  def id(socket) do
    "socket:#{socket.assigns.conn_id}"
  end
end
