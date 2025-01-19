defmodule NervesDevServerWeb.Router do
  use NervesDevServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NervesDevServerWeb.Controllers do
    pipe_through :api
    get "/", IndexController, :index
  end
end
