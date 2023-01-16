defmodule Pulsarius.ConfigurationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.Configurations` context.
  """

  @doc """
  Generate a configuration.
  """
  def configuration_fixture(attrs \\ %{}) do
    {:ok, configuration} =
      attrs
      |> Enum.into(%{
        frequency_check_in_seconds: 42,
        url_to_monitor: "some url_to_monitor"
      })
      |> Pulsarius.Configurations.create_configuration()

    configuration
  end
end
