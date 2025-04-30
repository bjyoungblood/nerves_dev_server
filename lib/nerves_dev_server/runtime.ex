defmodule NervesDevServer.Runtime do
  @moduledoc false

  @callback cpu_temperature() :: float() | nil
  @callback memory_stats() :: %{used_mb: integer(), total_mb: integer()} | nil
  @callback load_average() :: String.t()
end

defmodule NervesDevServer.Runtime.Target do
  @moduledoc false

  alias NervesMOTD.Runtime.Target

  @behaviour NervesDevServer.Runtime

  @impl NervesDevServer.Runtime
  def cpu_temperature() do
    case Target.cpu_temperature() do
      {:ok, float} -> Float.round(float, 1)
      _ -> nil
    end
  end

  @impl NervesDevServer.Runtime
  def memory_stats() do
    case Target.memory_stats() do
      {:ok, stats} -> stats
      _ -> nil
    end
  end

  @impl NervesDevServer.Runtime
  def load_average() do
    case NervesMOTD.Runtime.Target.load_average() do
      [a, b, c | _] -> Enum.join([a, b, c], " / ")
      _ -> nil
    end
  end
end
