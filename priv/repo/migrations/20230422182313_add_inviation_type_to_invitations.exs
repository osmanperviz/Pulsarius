defmodule Pulsarius.Repo.Migrations.AddInviationTypeToInvitations do
  use Ecto.Migration

  def change do
    alter table(:user_invitations) do
      add :type, :string, default: "email"
    end
  end
end
