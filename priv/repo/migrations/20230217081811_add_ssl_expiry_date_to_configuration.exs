defmodule Pulsarius.Repo.Migrations.AddSslExpiryDateToConfiguration do
  use Ecto.Migration

  def change do
    alter table(:configuration) do
      add :ssl_expiry_date, :naive_datetime
      add :ssl_notify_before_in_days, :string

      add :domain_expiry_date, :naive_datetime
      add :domain_notify_before_in_days, :string
    end
  end
end
