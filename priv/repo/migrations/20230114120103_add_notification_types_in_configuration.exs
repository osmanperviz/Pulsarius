defmodule Pulsarius.Repo.Migrations.AddNotificationTypesInConfiguration do
  use Ecto.Migration

  def change do
    alter table(:configuration) do
      add :email_notification, :boolean, default: false
      add :sms_notification, :boolean, default: false
    end
  end
end
