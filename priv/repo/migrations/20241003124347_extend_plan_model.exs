defmodule Pulsarius.Repo.Migrations.ExtendPlanModel do
  use Ecto.Migration

  def change do
    alter table(:plans) do
      remove :charging_interval
      remove :price_in_cents
      remove :stripe_price_id
      remove :subscription_type

      add :monthly_price_in_cents, :integer
      add :yearly_price_in_cents, :integer
      add :monthly_stripe_price_id, :string
      add :yearly_stripe_price_id, :string
    end
  end
end
