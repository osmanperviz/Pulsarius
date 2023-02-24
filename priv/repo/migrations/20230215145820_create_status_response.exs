defmodule Pulsarius.Repo.Migrations.CreateStatusResponse do
  use Ecto.Migration

  def change do
    create table(:status_responses, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :occured_at, :naive_datetime
      add :response_time_in_ms, :integer

      add :monitor_id, references(:monitoring, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:status_responses, [:monitor_id])
  end
end
