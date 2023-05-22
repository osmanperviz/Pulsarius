defmodule PulsariusWeb.IncidentsLive.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.Incidents
  alias Pulsarius.Monitoring

  import PulsariusWeb.MonitorLive.IncidentsComponents
  import PulsariusWeb.CoreComponents

  @impl true
  def mount(%{"id" => monitor_id}, _session, socket) do
    monitor = Monitoring.get_monitor!(monitor_id)

    {:ok,
     socket
     |> assign(:incidents, Incidents.list_incidents(monitor_id))
     |> assign(:monitor, monitor)}
  end

  def handle_event("delete-incident", %{"id" => incident_id, "monitor-id" => monitor_id}, socket) do
    incident = Incidents.get_incident!(incident_id)
    {:ok, _incident} = Incidents.delete_incident(incident)

    {:noreply,
     socket
     |> put_flash(:info, "Incident deleted!")
     |> push_redirect(to: Routes.incidents_index_path(PulsariusWeb.Endpoint, :index, monitor_id))}
  end
end
