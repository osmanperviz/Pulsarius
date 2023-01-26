defmodule Pulsarius.Repo.Migrations.AddAccountIdToMonitor do
  use Ecto.Migration

  def change do
    alter table(:monitoring) do
      add :account_id, references(:accounts, on_delete: :delete_all, type: :uuid)
    end
  end
end
