defmodule Pulsarius.Repo.Migrations.AddRulesColumnToPlanTable do
  use Ecto.Migration

  def change do
    alter table(:plans) do
      add :rules, :map, default: %{}
    end
  end
end
