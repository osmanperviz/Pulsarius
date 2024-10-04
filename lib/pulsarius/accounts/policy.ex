defmodule Pulsarius.Accounts.Policy do
  @moduledoc """
    Policy module for checking accounts limits.
  """
  alias Pulsarius.Monitoring

  def can?(account, :create_monitor) do
    max_monitors = get_config(account, :monitoring_limit)
    number_of_monitors = Monitoring.list_monitoring(account.id) |> Enum.count()

    max_monitors > number_of_monitors
  end

  def can?(account, :add_user) do
    max_users = get_config(account, :user_seats)
    number_of_users = Pulsarius.Accounts.list_users(account.id) |> Enum.count()

    max_users > number_of_users
  end

  def can?(account, :domain_monitor) do
    get_config(account, :domain_monitor)
  end

  def can?(account, :ssl_monitor) do
    get_config(account, :ssl_monitor)
  end

  defp get_config(account, rule) do
    config = Application.fetch_env!(:pulsarius, :feature_plans)
    config[account.type][rule]
  end
end
