defmodule Pulsarius.Repo.Migrations.AddStatusFieldToIncidentEntity do
  use Ecto.Migration

  def change do
    alter table(:incidents) do
      add :status, :string
    end
  end
end
