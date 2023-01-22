defmodule Pulsarius.Repo.Migrations.AddSlackNotificationFieldsToConfiguration do
  use Ecto.Migration

  def change do
    alter table(:configuration) do
      add :slack_notification, :boolean, default: false
      add :slack_notification_webhook_url, :string
    end
  end
end
