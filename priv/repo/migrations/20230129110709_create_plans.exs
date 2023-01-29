defmodule Pulsarius.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans, primary_key: false) do
      add :id, :uuid, primary_key: true 
      add :name, :string
      add :description, :text
      add :charging_interval, :integer
      add :price_in_cents, :integer
      add :stripe_price_id, :string

      timestamps()
    end

    create index(:plans, [:name])
  end
end