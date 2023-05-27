defmodule Pulsarius.Repo.Migrations.AddScreenshotUrlToIncident do
  use Ecto.Migration

  def change do
    alter table(:incidents) do
      add :screenshot_url, :string
    end
  end
end
