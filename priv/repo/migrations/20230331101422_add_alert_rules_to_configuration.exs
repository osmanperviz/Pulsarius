defmodule Pulsarius.Repo.Migrations.AddAlertRulesToConfiguration do
  use Ecto.Migration

  def change do
    alter table(:configuration) do
      add :alert_rule, :string
      add :alert_condition, :string
    end
  end
end
