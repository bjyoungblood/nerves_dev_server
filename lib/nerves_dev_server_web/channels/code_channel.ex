defmodule NervesDevServerWeb.Channels.CodeChannel do
  @moduledoc false
  use Phoenix.Channel

  alias NervesDevServer.CodeCompiler

  @impl Phoenix.Channel
  def join(_topic, _payload, socket) do
    {:ok, %{"dirtyModules" => dirty_modules()}, socket}
  end

  @impl Phoenix.Channel
  def handle_in("compile_code", %{"code" => code} = params, socket) do
    file = Map.get(params, "file", "nofile")
    {status, diagnostics} = CodeCompiler.compile_code(code, file)

    {:reply,
     {status,
      %{
        "diagnostics" => diagnostics,
        "dirtyModules" => dirty_modules()
      }}, socket}
  end

  def handle_in("get_dirty_modules", _params, socket) do
    {:reply, CodeCompiler.dirty_modules(), socket}
  end

  defp dirty_modules(), do: Enum.map(CodeCompiler.dirty_modules(), &inspect/1)
end
