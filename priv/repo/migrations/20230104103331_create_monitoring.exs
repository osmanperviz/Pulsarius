defmodule Pulsarius.Repo.Migrations.CreateMonitoring do
  use Ecto.Migration

  def change do
    create table(:monitoring) do

      timestamps()
    end
  end
end
