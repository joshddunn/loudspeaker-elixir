defmodule Myapp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :account_id, :string
      add :jti, :string
      add :token, :string
      add :token_exp, :integer

      timestamps()
    end

  end
end
