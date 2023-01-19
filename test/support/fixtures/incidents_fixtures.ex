defmodule Pulsarius.IncidentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.Incidents` context.
  """

  @doc """
  Generate a incident.
  """
  def incident_fixture(attrs \\ %{}) do
    {:ok, incident} =
      attrs
      |> Enum.into(%{
        occured_at: ~N[2023-01-16 09:43:00],
        page_response: "some page_response",
        resolved_at: ~N[2023-01-16 09:43:00]
      })
      |> Pulsarius.Incidents.create_incident()

    incident
  end
end
