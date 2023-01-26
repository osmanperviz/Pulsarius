defmodule Pulsarius.Repo.Migrations.AddRelationshipBetweenUserAndAccount do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :account_id, references(:accounts, on_delete: :delete_all, type: :uuid)
    end
  end
end
