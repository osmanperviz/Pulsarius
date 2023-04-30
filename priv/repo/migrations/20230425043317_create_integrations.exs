defmodule Pulsarius.Repo.Migrations.CreateIntegrations do
  use Ecto.Migration

  def change do
    create table(:integrations) do
      add :name, :string
      add :channel_id, :string
      add :type, :string
      add :channel_name, :string
      add :webhook_url, :string

      add :account_id, references(:accounts, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:integrations, [:account_id])
  end
end
