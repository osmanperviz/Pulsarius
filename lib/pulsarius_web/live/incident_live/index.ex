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
end
