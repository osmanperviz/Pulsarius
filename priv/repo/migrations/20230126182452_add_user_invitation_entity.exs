defmodule Pulsarius.Repo.Migrations.AddUserInvitationEntity do
  use Ecto.Migration

  def change do
    create table(:user_invitations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :account_id, references(:accounts, on_delete: :delete_all, type: :uuid)
      add :token, :string
      add :email, :string

      timestamps()
    end

    create index(:user_invitations, [:token, :email])
    create unique_index(:user_invitations, [:email])
  end
end
