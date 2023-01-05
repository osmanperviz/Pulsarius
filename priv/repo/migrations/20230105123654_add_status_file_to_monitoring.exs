defmodule Pulsarius.Repo.Migrations.AddStatusFileToMonitoring do
  use Ecto.Migration

  def change do
    alter table(:monitoring) do
      add :status, :string
    end
  end
end
