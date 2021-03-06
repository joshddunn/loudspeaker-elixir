defmodule MyappWeb.Router do
  use MyappWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyappWeb do
    pipe_through :api

    get "/ping", UserController, :ping

    get "/auth", UserController, :verify_auth
    post "/auth", UserController, :auth

    post "/slack", UserController, :slack

    post "/recording", UserController, :recording
  end
end
