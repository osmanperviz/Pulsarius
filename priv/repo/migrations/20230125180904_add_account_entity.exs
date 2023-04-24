defmodule Pulsarius.Repo.Migrations.AddAccountEntity do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :type, :string
      add :stripe_id, :string
      add :invitation_token, :string

      timestamps()
    end
  end
end
