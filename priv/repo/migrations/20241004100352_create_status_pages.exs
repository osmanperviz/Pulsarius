defmodule Pulsarius.Repo.Migrations.CreateStatusPages do
  use Ecto.Migration

  def change do
    create table(:status_pages, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :homepage_url, :string
      add :layout, :string
      add :logo_url, :string
      add :status_history_in_days, :integer
      add :is_public, :boolean, default: false

      add :account_id, references(:accounts, on_delete: :delete_all, type: :uuid)

      timestamps()
    end
  end
end
