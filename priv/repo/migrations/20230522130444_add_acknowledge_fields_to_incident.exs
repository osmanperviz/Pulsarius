defmodule Pulsarius.Repo.Migrations.AddAcknowledgeFieldsToIncident do
  use Ecto.Migration

  def change do
    alter table(:incidents) do
      add :acknowledge_at, :naive_datetime
      add :acknowledge_by, :string
    end
  end
end
