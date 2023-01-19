defmodule Pulsarius.IncidentsTest do
  use Pulsarius.DataCase

  alias Pulsarius.Incidents

  describe "incidents" do
    alias Pulsarius.Incidents.Incident

    import Pulsarius.IncidentsFixtures

    @invalid_attrs %{occured_at: nil, page_response: nil, resolved_at: nil}

    test "list_incidents/0 returns all incidents" do
      incident = incident_fixture()
      assert Incidents.list_incidents() == [incident]
    end

    test "get_incident!/1 returns the incident with given id" do
      incident = incident_fixture()
      assert Incidents.get_incident!(incident.id) == incident
    end

    test "create_incident/1 with valid data creates a incident" do
      valid_attrs = %{
        occured_at: ~N[2023-01-16 09:43:00],
        page_response: "some page_response",
        resolved_at: ~N[2023-01-16 09:43:00]
      }

      assert {:ok, %Incident{} = incident} = Incidents.create_incident(valid_attrs)
      assert incident.occured_at == ~N[2023-01-16 09:43:00]
      assert incident.page_response == "some page_response"
      assert incident.resolved_at == ~N[2023-01-16 09:43:00]
    end

    test "create_incident/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Incidents.create_incident(@invalid_attrs)
    end

    test "update_incident/2 with valid data updates the incident" do
      incident = incident_fixture()

      update_attrs = %{
        occured_at: ~N[2023-01-17 09:43:00],
        page_response: "some updated page_response",
        resolved_at: ~N[2023-01-17 09:43:00]
      }

      assert {:ok, %Incident{} = incident} = Incidents.update_incident(incident, update_attrs)
      assert incident.occured_at == ~N[2023-01-17 09:43:00]
      assert incident.page_response == "some updated page_response"
      assert incident.resolved_at == ~N[2023-01-17 09:43:00]
    end

    test "update_incident/2 with invalid data returns error changeset" do
      incident = incident_fixture()
      assert {:error, %Ecto.Changeset{}} = Incidents.update_incident(incident, @invalid_attrs)
      assert incident == Incidents.get_incident!(incident.id)
    end

    test "delete_incident/1 deletes the incident" do
      incident = incident_fixture()
      assert {:ok, %Incident{}} = Incidents.delete_incident(incident)
      assert_raise Ecto.NoResultsError, fn -> Incidents.get_incident!(incident.id) end
    end

    test "change_incident/1 returns a incident changeset" do
      incident = incident_fixture()
      assert %Ecto.Changeset{} = Incidents.change_incident(incident)
    end
  end
end
