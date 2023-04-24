defmodule Pulsarius.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :admin, :boolean, default: false
      add :first_name, :string
      add :last_name, :string
      add :email, :string

      timestamps()
    end
  end
end
