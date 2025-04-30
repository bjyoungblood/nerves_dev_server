defmodule NervesDevServerWeb.Controllers.IndexController do
  @moduledoc false

  use NervesDevServerWeb, :controller

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    send_resp(conn, 200, Phoenix.json_library().encode!(%{status: "ok"}))
  end
end
