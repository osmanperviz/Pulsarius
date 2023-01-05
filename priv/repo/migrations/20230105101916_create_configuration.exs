defmodule Pulsarius.Repo.Migrations.CreateConfiguration do
  use Ecto.Migration

  def change do
    create table(:configuration, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :url_to_monitor, :string
      add :frequency_check_in_seconds, :string
      add :monitor_id, references(:monitoring, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:configuration, [:monitor_id])
  end
end
