defmodule Pulsarius.Repo.Migrations.AddStatusPageIdToMonitors do
  use Ecto.Migration

  def change do
    alter table(:monitoring) do
      add :status_page_id, references(:status_pages, type: :uuid)
    end
  end
end
