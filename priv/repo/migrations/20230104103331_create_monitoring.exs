defmodule Pulsarius.Repo.Migrations.CreateMonitoring do
  use Ecto.Migration

  def change do
    create table(:monitoring, primary_key: false) do
      add :id, :uuid, primary_key: true
      timestamps()
    end
  end
end
