defmodule NervesDevServerWeb.Channels.TelemetryChannel do
  @moduledoc false
  use Phoenix.Channel

  alias Nerves.Runtime.KV
  require Logger

  @default_telemetry_interval :timer.seconds(15)

  @impl Phoenix.Channel
  def join(_topic, _payload, socket) do
    socket = assign(socket, :telemetry_interval, @default_telemetry_interval)

    if Code.ensure_loaded?(Alarmist) do
      PropertyTable.subscribe(Alarmist, [:_, :status])
    end

    Process.send_after(self(), :after_join, 0)

    reply = %{
      "fwValid" => Nerves.Runtime.firmware_valid?(),
      "activePartition" => KV.get("nerves_fw_active") |> String.upcase(),
      "fwArchitecture" => KV.get_active("nerves_fw_architecture"),
      "fwPlatform" => KV.get_active("nerves_fw_platform"),
      "fwProduct" => KV.get_active("nerves_fw_product"),
      "fwVersion" => KV.get_active("nerves_fw_version"),
      "fwUuid" => KV.get_active("nerves_fw_uuid")
    }

    {:ok, reply, socket}
  end

  @impl Phoenix.Channel
  def handle_in(event, payload, socket) do
    IO.inspect(binding())
    {:noreply, socket}
  end

  @impl Phoenix.Channel
  def handle_info(:after_join, socket) do
    push_telemetry(socket)
    push_alarms(socket)

    Process.send_after(self(), :telemetry, socket.assigns.telemetry_interval)

    {:noreply, socket}
  end

  def handle_info(:telemetry, socket) do
    push_telemetry(socket)
    Process.send_after(self(), :telemetry, socket.assigns.telemetry_interval)
    {:noreply, socket}
  end

  def handle_info(%PropertyTable.Event{table: Alarmist}, socket) do
    push_alarms(socket)
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    Logger.warning("[DiagnosticsChannel] Unexpected message: #{inspect(msg)}")
    {:noreply, socket}
  end

  defp push_telemetry(socket) do
    memory_stats = runtime_mod().memory_stats()

    push(socket, "telemetry", %{
      "uptime" => uptime(),
      "loadAverage" => runtime_mod().load_average(),
      "cpuTemperature" => runtime_mod().cpu_temperature(),
      "memory" =>
        if(memory_stats != nil,
          do: %{"usedMb" => memory_stats.used_mb, "totalMb" => memory_stats.size_mb}
        )
    })

    :ok
  end

  defp push_alarms(socket) do
    if Code.ensure_loaded?(Alarmist) do
      push(socket, "alarms", %{
        "alarms" => Enum.map(Alarmist.current_alarms(), &inspect/1)
      })
    end
  end

  # https://github.com/nerves-project/nerves_motd/blob/a93b91a35c4bbb88c755d558776a314b2811e5d2/lib/nerves_motd.ex#L243
  # https://github.com/erlang/otp/blob/1c63b200a677ec7ac12202ddbcf7710884b16ff2/lib/stdlib/src/c.erl#L1118
  @spec uptime() :: IO.chardata()
  defp uptime() do
    {uptime, _} = :erlang.statistics(:wall_clock)
    {d, {h, m, s}} = :calendar.seconds_to_daystime(div(uptime, 1000))
    days = if d > 0, do: :io_lib.format("~b days, ", [d]), else: []
    hours = if d + h > 0, do: :io_lib.format("~b hours, ", [h]), else: []
    minutes = if d + h + m > 0, do: :io_lib.format("~b minutes and ", [m]), else: []
    seconds = :io_lib.format("~b", [s])
    millis = if d + h + m == 0, do: :io_lib.format(".~3..0b", [rem(uptime, 1000)]), else: []

    [days, hours, minutes, seconds, millis, " seconds"] |> IO.iodata_to_binary()
  end

  defp runtime_mod() do
    Application.get_env(
      :nerves_dev_server,
      :runtime_mod,
      NervesDevServer.Runtime.Target
    )
  end
end
