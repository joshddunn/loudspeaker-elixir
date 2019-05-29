defmodule Myapp.Slack.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :account_id, :string
    field :jti, :string
    field :name, :string
    field :token, :string
    field :token_exp, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :account_id, :jti, :token, :token_exp])
    |> set_jti(attrs)
    |> validate_required([:name, :account_id, :jti, :token, :token_exp])
  end

  defp set_jti(user, attrs) do
    if user.data.jti || Map.has_key?(attrs, :jti) do
      user
    else
      changes = user.changes |> Map.put(:jti, SecureRandom.hex(24))
      user |> Map.put(:changes, changes)
    end
  end
end
