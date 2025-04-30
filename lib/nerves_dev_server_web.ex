defmodule NervesDevServerWeb do
  @moduledoc false

  @spec router() :: Macro.t()
  def router() do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @spec channel() :: Macro.t()
  def channel() do
    quote do
      use Phoenix.Channel
    end
  end

  @spec controller() :: Macro.t()
  def controller() do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: NervesDevServerWeb.Layouts]

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  @spec verified_routes() :: Macro.t()
  def verified_routes() do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: NervesDevServerWeb.Endpoint,
        router: NervesDevServerWeb.Router
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
