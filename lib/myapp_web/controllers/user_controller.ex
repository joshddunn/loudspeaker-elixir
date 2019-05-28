defmodule MyappWeb.UserController do
  use MyappWeb, :controller

  alias Myapp.Slack
  alias Myapp.Slack.User

  action_fallback MyappWeb.FallbackController

  def slack(conn, %{"user_id" => account_id, "user_name" => name}) do
    if verify_slack_signature(conn) do
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
    else
      send_resp(conn, :unauthorized, "")
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

    if validate_user(token) do
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

  defp verify_slack_signature(conn) do
    signature = get_req_header(conn, "x-slack-signature") |> List.first
    {timestamp, _} = get_req_header(conn, "x-slack-request-timestamp") |> List.first |> Integer.parse
    raw_body = conn.assigns[:raw_body] |> List.first
    sig_basestring = "v0:#{timestamp}:#{raw_body}"
    sha = :crypto.hmac(:sha256, Application.fetch_env!(:slack, :signing_secret), sig_basestring) |> Base.encode16 |> String.downcase
    signature == "v0=#{sha}" && abs(timestamp - current_time()) < 300
  end

  defp validate_user(token) do
    {result, payload} = MyApp.Token.verify_and_validate(token)
    user = Slack.get_user(payload["user_id"])
    result == :ok && user && user.jti == payload["jti"]
  end
end
