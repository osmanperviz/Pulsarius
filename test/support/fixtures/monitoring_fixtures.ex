defmodule Pulsarius.MonitoringFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.Monitoring` context.
  """

  import Pulsarius.AccountsFixtures

  @doc """
  Generate a monitor.
  """
  def monitor_fixture(account, attrs \\ %{}) do
    params =
      attrs
      |> Enum.into(%{
        name: "some monitor",
        status: :active
      })

    {:ok, monitor} = Pulsarius.Monitoring.create_monitor(account, params)

    monitor
  end
end
