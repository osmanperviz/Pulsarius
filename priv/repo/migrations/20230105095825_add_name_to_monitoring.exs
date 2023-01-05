defmodule Pulsarius.Repo.Migrations.AddNameToMonitoring do
  use Ecto.Migration

  def change do
    alter table(:monitors) do
      add :name, :string, null: false
    end
  end
end
