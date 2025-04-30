defmodule NervesDevServerWeb.Socket do
  @moduledoc false

  use Phoenix.Socket

  require Logger

  channel "code", NervesDevServerWeb.Channels.CodeChannel
  channel "telemetry", NervesDevServerWeb.Channels.TelemetryChannel

  @impl Phoenix.Socket
  @spec connect(any(), Phoenix.Socket.t(), any()) :: {:ok, Phoenix.Socket.t()} | {:error, map()}
  def connect(params, socket, _connect_info) do
    case check_token(params["token"], NervesDevServer.token_secret()) do
      :ok ->
        {:ok, assign(socket, :conn_id, System.unique_integer([:positive]))}

      {:error, reason} ->
        Logger.warning("[NervesDevServer] Rejected websocket connection: #{inspect(reason)}")
        {:error, %{"reason" => reason}}
    end
  end

  @impl Phoenix.Socket
  def id(socket) do
    "socket:#{socket.assigns.conn_id}"
  end

  defp check_token(_, false), do: :ok
  defp check_token(nil, _), do: {:error, :auth_required}

  defp check_token(token, secret) do
    case Phoenix.Token.verify(secret, "user socket", token, max_age: 120) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
