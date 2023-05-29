defmodule PulsariusWeb.IncidentsLive.Account do
  use PulsariusWeb, :live_view

  alias Pulsarius.Incidents

  import PulsariusWeb.MonitorLive.IncidentsComponents
  import PulsariusWeb.CoreComponents

  def mount(%{"id" => account_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:incidents, Incidents.get_incidents_for_account(account_id))}
  end

  def handle_event("delete-incident", %{"id" => incident_id}, socket) do
    incident = Incidents.get_incident!(incident_id)
    {:ok, _incident} = Incidents.delete_incident(incident)

    {:noreply,
     socket
     |> put_flash(:info, "Incident deleted!")
     |> push_redirect(
       to: Routes.incidents_account_path(PulsariusWeb.Endpoint, :index, socket.assigns.account.id)
     )}
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
