defmodule Pulsarius.IncidentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.Incidents` context.
  """

  @doc """
  Generate a incident.
  """
  def incident_fixture(monitor, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        occured_at: DateTime.utc_now(),
        page_response: "some page_response",
        resolved_at: DateTime.utc_now()
      })

    {:ok, incident} = Pulsarius.Incidents.create_incident(monitor, attrs)

    incident
  end
end
