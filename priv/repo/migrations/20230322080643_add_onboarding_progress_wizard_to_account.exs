defmodule Pulsarius.Repo.Migrations.AddOnboardingProgressWizardToAccount do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :show_onboard_progress_wizard, :boolean, default: true
    end
  end
end
