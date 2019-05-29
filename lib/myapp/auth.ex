defmodule Myapp.Auth do

  alias Myapp.Slack

  def generate_jwt(user) do
    extra_claims = %{"user_id" => user.id, "jti" => user.jti}
    Myapp.Token.generate_and_sign!(extra_claims)
  end

  def verify_jwt(nil) do
    nil
  end

  def verify_jwt(token) do
    {result, payload} = Myapp.Token.verify_and_validate(token)
    user = Slack.get_user(payload["user_id"])
    if result == :ok && user && user.jti == payload["jti"] do
      user
    else
      nil
    end
  end

  def generate_token(payload = %{}) do
    payload
    |> Map.put(:token, SecureRandom.urlsafe_base64)
    |> Map.put(:token_exp, current_time() + 120)
  end

  def verify_token(token) do
    if (user = Slack.get_user_by(token: token)) && user.token_exp > current_time() do
      user
    else
      nil
    end
  end

  def verify_slack_signature(conn) do
    signature = Plug.Conn.get_req_header(conn, "x-slack-signature") |> List.first
    {timestamp, _} = Plug.Conn.get_req_header(conn, "x-slack-request-timestamp") |> List.first |> Integer.parse
    raw_body = conn.assigns[:raw_body] |> List.first
    sig_basestring = "v0:#{timestamp}:#{raw_body}"
    sha = :crypto.hmac(:sha256, Application.fetch_env!(:slack, :signing_secret), sig_basestring) |> Base.encode16 |> String.downcase
    signature == "v0=#{sha}" && abs(timestamp - current_time()) < 300
  end

  defp current_time do
    DateTime.utc_now |> DateTime.to_unix
  end
end
