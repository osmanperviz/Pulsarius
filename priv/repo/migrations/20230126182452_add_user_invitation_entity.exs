defmodule Pulsarius.Repo.Migrations.AddUserInvitationEntity do
  use Ecto.Migration

  def change do
    create table(:user_invitations) do
      add :account_id, references(:accounts, on_delete: :delete_all, type: :uuid)
      add :token, :string
      add :email, :string

      timestamps()
    end

    create index(:user_invitations, [:token])
  end
end
