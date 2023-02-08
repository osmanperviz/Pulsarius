defmodule Pulsarius.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :status, :string
      add :cancel_at, :naive_datetime
      add :current_period_end_at, :naive_datetime
      add :stripe_id, :string

      add :plan_id, references(:plans, on_delete: :nothing, type: :uuid)
      add :account_id, references(:accounts, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:subscriptions, [:plan_id])
    create index(:subscriptions, [:account_id])
    create index(:subscriptions, [:stripe_id])
  end
end
