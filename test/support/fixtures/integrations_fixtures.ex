defmodule Pulsarius.IntegrationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.Integrations` context.
  """

  @doc """
  Generate a integration.
  """
  def integration_fixture(attrs \\ %{}) do
    {:ok, integration} =
      attrs
      |> Enum.into(%{
        channel_name: "some channel_name",
        name: "some name",
        type: "some type",
        webhook_url: "some webhook_url"
      })
      |> Pulsarius.Integrations.create_integration()

    integration
  end
end
