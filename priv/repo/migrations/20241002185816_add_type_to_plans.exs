defmodule Pulsarius.Repo.Migrations.AddTypeToPlans do
  use Ecto.Migration

  def change do
    alter table(:plans) do
      add :subscription_type, :string
    end
  end
end
