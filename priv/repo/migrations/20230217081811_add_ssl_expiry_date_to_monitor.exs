defmodule Pulsarius.Repo.Migrations.AddSslExpiryDateToMonitor do
  use Ecto.Migration

  def change do
    alter table(:monitoring) do
      add :ssl_expiry_date, :naive_datetime
    end
  end
end
