defmodule Pulsarius.Repo.Migrations.CreateIncidents do
  use Ecto.Migration

  def change do
    create table(:incidents, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :occured_at, :naive_datetime
      add :resolved_at, :naive_datetime
      add :page_response, :text
      add :monitor_id, references(:monitoring, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:incidents, [:monitor_id])
  end
end
