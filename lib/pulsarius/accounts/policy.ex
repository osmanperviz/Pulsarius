defmodule Pulsarius.Accounts.Policy do
  @moduledoc """
    Policy module for checking accounts limits.
  """
  alias Pulsarius.Monitoring

  def can?(account, :save_monitor) do
    max_monitors = get_max_monitors(account)
    number_of_monitors = Monitoring.list_monitoring(account.id) |> Enum.count()

    max_monitors > number_of_monitors
  end

  def can?(account, :add_user) do
    max_users = get_max_users(account)
    number_of_users = Pulsarius.Accounts.list_users(account.id) |> Enum.count()

    max_users > number_of_users
  end

  defp get_max_monitors(account) do
    config = Application.fetch_env!(:pulsarius, :feature_plans)

    config[account.type][:monitoring_limit]
  end

  defp get_max_users(account) do
    account = Pulsarius.Repo.preload(account, subscription: [:plan])
    account.subscription.plan.rules["max_users"]
  end
end
