defmodule Pulsarius.Repo.Migrations.AddStatusToUserInvitation do
  use Ecto.Migration

  def change do
    alter table(:user_invitations) do
      add :status, :string, default: "pending"
    end
  end
end
