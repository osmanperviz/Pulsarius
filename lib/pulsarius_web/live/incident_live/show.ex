defmodule PulsariusWeb.IncidentsLive.Show do
  use PulsariusWeb, :live_view

  alias Pulsarius.Incidents
  alias Pulsarius.Incidents.Incident
  alias Pulsarius.Monitoring

  import PulsariusWeb.MonitorLive.IncidentsComponents
  import PulsariusWeb.CoreComponents

  @impl true
  def mount(%{"monitor_id" => monitor_id, "incident_id" => incident_id}, _session, socket) do
    incident = Incidents.get_incident!(incident_id)

    {:ok,
     socket
     |> assign(:incident, incident)
     |> assign(:monitor, Monitoring.get_monitor!(monitor_id))
     |> assign(:duration, calculate_duration(incident))}
  end

  def handle_event("delete-incident", _params, socket) do
    {:ok, _monitor} = Incidents.delete_incident(socket.assigns.incident)
    
     {:noreply,
         socket
         |> put_flash(:info, "Incident deleted!")
         |> push_redirect(to: Routes.incidents_index_path(PulsariusWeb.Endpoint, :index, socket.assigns.monitor.id))}
  end

  defp calculate_duration(%Incident{status: :active} = _incident) do
    "Ongoing"
  end

  defp calculate_duration(%Incident{} = incident) do
    humanized_duration(incident.occured_at, incident.resolved_at)
  end
end
