defmodule Pulsarius.MonitoringFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.Monitoring` context.
  """

  @doc """
  Generate a monitor.
  """
  def monitor_fixture(attrs \\ %{}) do
    {:ok, monitor} =
      attrs
      |> Enum.into(%{})
      |> Pulsarius.Monitoring.create_monitor()

    monitor
  end
end
