defmodule Myapp.Token do
  use Joken.Config

  def token_config, do: default_claims(default_exp: 60 * 60 * 24 * 30)
end
