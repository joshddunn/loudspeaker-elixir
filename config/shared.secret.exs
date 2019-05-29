use Mix.Config

slack_signing_secret =
  System.get_env("SLACK_SIGNING_SECRET") ||
    raise """
    environment variable SLACK_SIGNING_SECRET is missing.
    """

slack_api_token =
  System.get_env("SLACK_API_TOKEN") ||
    raise """
    environment variable SLACK_API_TOKEN is missing.
    """

config :slack,
  signing_secret: slack_signing_secret,
  api_token: slack_api_token
