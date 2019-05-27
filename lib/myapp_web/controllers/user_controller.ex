defmodule MyappWeb.UserController do
  use MyappWeb, :controller

  alias Myapp.Slack
  alias Myapp.Slack.User

  action_fallback MyappWeb.FallbackController

  # def index(conn, _params) do
  #   users = Slack.list_users()
  #   render(conn, "index.json", users: users)
  # end

  # def create(conn, %{"user" => user_params}) do
  #   with {:ok, %User{} = user} <- Slack.create_user(user_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.user_path(conn, :show, user))
  #     |> render("show.json", user: user)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   user = Slack.get_user!(id)
  #   render(conn, "show.json", user: user)
  # end

  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Slack.get_user!(id)

  #   with {:ok, %User{} = user} <- Slack.update_user(user, user_params) do
  #     render(conn, "show.json", user: user)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   user = Slack.get_user!(id)

  #   with {:ok, %User{}} <- Slack.delete_user(user) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end

  def auth(conn, %{"auth" => %{"token" => token}}) do
    {token_int, token_string} = token |> Integer.parse

    if token_int + 120000 < System.system_time(:millisecond) do
      if (user = Slack.get_user_by(token: token)) do
        extra_claims = %{"user_id" => user.id, "jti" => user.jti}
        jwt = MyApp.Token.generate_and_sign!(extra_claims)
        conn
        |> put_resp_header("Authorization", jwt)
        |> render(conn, "success.json")
      else
        send_resp(conn, :unauthorized, "")
      end
    else
      send_resp(conn, :bad_request, "")
    end
  end

  def verify_auth(conn, _params) do
    token = get_req_header(conn, "authorization") |> List.first

    if token do
      {result, claims} = MyApp.Token.verify_and_validate(token)
      if result == :ok do
        render(conn, "success.json")
      else
        send_resp(conn, :unauthorized, "")
      end
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def ping(conn, _params) do
    render(conn, "success.json")
  end
end
