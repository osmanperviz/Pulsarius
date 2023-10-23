defmodule Pulsarius.Repo.Migrations.CreateUsersToken do
  use Ecto.Migration

  def change do
    create table(:users_token) do
      add :token, :binary, null: false
      add :sent_to, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)

      timestamps(updated_at: false)
    end

    create index(:users_token, [:user_id])
  end
end
