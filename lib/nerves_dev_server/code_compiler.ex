defmodule NervesDevServer.CodeCompiler do
  @moduledoc """
  A GenServer responsible for compiling code and tracking which module(s) are
  now dirty.
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

  @spec start_link(keyword()) :: GenServer.on_start()
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

  @spec do_compile(binary(), binary()) :: {:ok | :error, [module()], iodata()}
  defp do_compile(code, file) do
    {{result, modules_or_err}, diagnostics} =
      Code.with_diagnostics(fn ->
        try do
          # Store the current value of the ignore_module_conflict option
          # and then disable it.
          %{ignore_module_conflict: prev_opt} =
            Code.compiler_options(ignore_module_conflict: true)

          result = Code.compile_string(code, file)

          # Restore the previous value of the ignore_module_conflict option
          _ = Code.compiler_options(ignore_module_conflict: prev_opt)

          # Map over the result to get the names of any created modules
          modules = Enum.map(result, &elem(&1, 0))
          _ = Code.purge_compiler_modules()

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

    {result, modules_or_err, format_diagnostics(diagnostics)}
  end

  defp format_diagnostics(diagnostics) do
    Enum.map_join(diagnostics, &format_diagnostic/1)
  end

  defp format_diagnostic(%{severity: s, position: p, file: f, message: m} = diagnostic) do
    :elixir_errors.format_snippet(s, p, f, m, nil, diagnostic)
  end
end
