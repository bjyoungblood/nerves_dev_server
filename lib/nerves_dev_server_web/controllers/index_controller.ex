defmodule NervesDevServerWeb.Controllers.IndexController do
  use NervesDevServerWeb, :controller

  def index(conn, _params) do
    send_resp(conn, 200, Phoenix.json_library().encode!(%{status: "ok"}))
  end
end
