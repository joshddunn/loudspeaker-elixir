defmodule MyappWeb.UserController do
  use MyappWeb, :controller

  alias Myapp.Slack
  alias Myapp.Slack.User

  action_fallback MyappWeb.FallbackController

  def slack(conn, %{"user_id" => account_id, "user_name" => name}) do
    # need to validate stripe signing secret

    user_params = %{
      account_id: account_id,
      name: name,
      token: SecureRandom.urlsafe_base64,
      token_exp: current_time() + 120
    }

    if (existing_user = Slack.get_user_by(account_id: account_id)) do
      {:ok, user} = Slack.update_user(existing_user, user_params)
      render(conn, "slack.json", user: user)
    else
      {:ok, user} = Slack.create_user(user_params)
      render(conn, "slack.json", user: user)
    end
  end

  def auth(conn, %{"auth" => %{"token" => token}}) do
    if (user = Slack.get_user_by(token: token)) && user.token_exp < current_time() do
      extra_claims = %{"user_id" => user.id, "jti" => user.jti}
      jwt = MyApp.Token.generate_and_sign!(extra_claims)
      conn
      |> put_resp_header("Authorization", jwt)
      |> render(conn, "success.json")
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def verify_auth(conn, _params) do
    token = get_req_header(conn, "authorization") |> List.first
    {result, _} = MyApp.Token.verify_and_validate(token)

    if result == :ok do
      render(conn, "success.json")
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def ping(conn, _params) do
    render(conn, "success.json")
  end

  defp current_time do
    DateTime.utc_now |> DateTime.to_unix
  end
end
