defmodule Pulsarius.Repo.Migrations.AddBenefitsColumnToPlan do
  use Ecto.Migration

  def change do
    alter table(:plans) do
      add :benefits, {:array, :string}
    end
  end
end
