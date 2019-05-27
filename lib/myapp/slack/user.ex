defmodule Myapp.Slack.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :account_id, :string
    field :jti, :string
    field :name, :string
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :account_id, :jti, :token])
    |> validate_required([:name, :account_id, :jti, :token])
  end
end
