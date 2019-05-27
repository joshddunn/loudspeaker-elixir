defmodule MyappWeb.Router do
  use MyappWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyappWeb do
    pipe_through :api

    get "/ping", UserController, :ping

    post "/auth", UserController, :auth
    get "/auth", UserController, :verify_auth

    post "/slack", UserController, :slack
    # post "/recording", RecordingController, :create
  end
end
