defmodule Pulsarius.Repo.Migrations.AddUserToUserInvitation do
  use Ecto.Migration

  def change do
    alter table(:user_invitations) do
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)
    end
  end
end
