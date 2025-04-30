defmodule NervesDevServer do
  @moduledoc File.read!(Path.join([__DIR__, "..", "README.md"]))
             |> String.split("\n")
             |> Enum.drop(1)
             |> Enum.join("\n")

  @spec token_secret() :: String.t() | false
  def token_secret() do
    Application.get_env(:nerves_dev_server, :token_secret)
  end
end
