defmodule MyappWeb.UserController do
  use MyappWeb, :controller

  alias Myapp.Slack
  alias Myapp.Slack.User
  alias Myapp.Auth

  action_fallback MyappWeb.FallbackController

  def slack(conn, %{"user_id" => account_id, "user_name" => name}) do
    if Auth.verify_slack_signature(conn) do

      user_params = Auth.generate_token(%{
        account_id: account_id,
        name: name,
      })

      if (existing_user = Slack.get_user_by(account_id: account_id)) do
        {:ok, user} = Slack.update_user(existing_user, user_params)
        render(conn, "slack.json", user: user)
      else
        {:ok, user} = Slack.create_user(user_params)
        render(conn, "slack.json", user: user)
      end
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def auth(conn, %{"auth" => %{"token" => token}}) do
    if (user = Auth.verify_token(token)) do
      conn
      |> put_resp_header("Authorization", Auth.generate_jwt(user))
      |> render(conn, "success.json")
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def verify_auth(conn, _params) do
    token = get_req_header(conn, "authorization") |> List.first
    if Auth.verify_jwt(token) do
      render(conn, "success.json")
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def ping(conn, _params) do
    render(conn, "success.json")
  end
end
