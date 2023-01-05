defmodule Pulsarius.Repo.Migrations.CreateConfiguration do
  use Ecto.Migration

  def change do
    create table(:configuration) do
      add :url_to_monitor, :string
      add :frequency_check_in_seconds, :integer
      add :monitor_id, references(:monitoring, on_delete: :nothing)

      timestamps()
    end

    create index(:configuration, [:monitor_id])
  end
end
