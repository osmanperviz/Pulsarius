defmodule Pulsarius.Repo.Migrations.AddOrganizationNameToAccount do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :organization_name, :string
    end
  end
end
