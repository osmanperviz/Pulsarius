defmodule Pulsarius.Repo.Migrations.AddStatusCodeToIncident do
  use Ecto.Migration

  def change do
    alter table(:incidents) do
      add :status_code, :integer
    end
  end
end
