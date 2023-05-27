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

  def handle_event("acknowledge-incident", %{"id" => incident_id}, socket) do
    email = socket.assigns.current_user.email
    incident = Incidents.get_incident!(incident_id)
    {:ok, incident} = Incidents.acknowledge_incident(incident, email)

    Pulsarius.broadcast("incidents", {:incident_acknowledged, incident})

    {:noreply,
     socket
     |> assign(:incidents, Incidents.list_incidents(socket.assigns.monitor.id))
     |> put_flash(:info, "Incident acknowledged!")}
  end

  def handle_event("resolve-incident", %{"id" => incident_id}, socket) do
    incident = Incidents.get_incident!(incident_id)
    {:ok, incident} = Incidents.resolve_incident(incident)

    Pulsarius.broadcast("incidents", {:incident_resolved, incident})

    {:noreply,
     socket
     |> assign(:incidents, Incidents.list_incidents(socket.assigns.monitor.id))
     |> put_flash(:info, "Incident resolved!")}
  end
end
