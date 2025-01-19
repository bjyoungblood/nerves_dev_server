defmodule NervesDevServer.CodeCompiler do
  @moduledoc """
  The CodeCompiler module is responsible for compiling code and tracking which
  module(s) are now dirty.
  """

  use GenServer

  @spec compile_code(binary(), binary()) :: {:ok | :error, binary()}
  def compile_code(code, file) do
    GenServer.call(__MODULE__, {:compile_code, code, file}, 10_000)
  end

  @spec dirty_modules() :: [module()]
  def dirty_modules() do
    GenServer.call(__MODULE__, :dirty_modules)
  end

  @spec start_link() :: GenServer.on_start()
  def start_link(_ \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    {:ok, %{dirty_modules: MapSet.new()}}
  end

  @impl GenServer
  def handle_call({:compile_code, code, file}, _from, state) do
    {result, modules, diagnostics} = do_compile(code, file)

    {:reply, {result, diagnostics},
     %{state | dirty_modules: MapSet.union(state.dirty_modules, MapSet.new(modules))}}
  end

  def handle_call(:dirty_modules, _from, state) do
    {:reply, MapSet.to_list(state.dirty_modules), state}
  end

  @spec do_compile(binary(), binary()) ::
          {:ok, [module()], [Code.diagnostic(:warning | :error)]}
          | {:error, [module()], binary() | iodata()}
  defp do_compile(code, file) do
    {{result, modules}, diagnostics} =
      Code.with_diagnostics(fn ->
        try do
          result = Code.compile_string(code, file)
          modules = Enum.map(result, &elem(&1, 0))
          Code.purge_compiler_modules()
          {:ok, modules}
        rescue
          err -> {:error, err}
        end
      end)

    result =
      if result != :ok or Enum.any?(diagnostics, &(&1.severity == :error)) do
        :error
      else
        :ok
      end

    {result, modules, format_diagnostics(diagnostics)}
  end

  defp format_diagnostics(diagnostics) do
    Enum.map(diagnostics, &format_diagnostic/1)
    |> Enum.join()
  end

  defp format_diagnostic(%{severity: s, position: p, file: f, message: m} = diagnostic) do
    :elixir_errors.format_snippet(s, p, f, m, nil, diagnostic)
  end
end
