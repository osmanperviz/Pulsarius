defmodule PulsariusWeb.MonitorLive.TotalAvailabilityWidget do
  use Phoenix.LiveView,
    container: {:div, class: "box-item right"}
  
  import PulsariusWeb.LiveHelpers

  alias Pulsarius.Monitoring
  alias Pulsarius.Incidents

  def mount(:not_mounted_at_router, %{"monitor" => monitor}, socket) do
    monitor = Monitoring.get_monitor!(monitor.id) |> Pulsarius.Repo.preload(:active_incident)
    most_recent_incident = Incidents.get_most_recent_incident!(monitor.id)

    start_timer()

    {:ok,
     socket
     |> assign(:monitor, monitor)
     |> assign(:active_incident, monitor.active_incident)
     |> assign(:title, title(monitor))
     |> assign(:last_incident, most_recent_incident)
     |> assign(:humanized_time, time(socket.assigns))}
  end

  def render(assigns) do
    ~H"""
    <div class="w-100">
      <div class="card box pb-2 pt-2  w-100">
        <div class="card-body">
          <h6><span class="abc"><%= @title %></span></h6>
          <h6><%= @humanized_time %></h6>
        </div>
      </div>
    </div>
    """
  end

  def handle_info(:tick, %{assigns: assigns} = socket) do
    humanized_time = time(assigns)

    {:noreply, assign(socket, :humanized_time, humanized_time)}
  end


  defp title(monitor) do
    cond do
      monitor.status == :active -> "Currently up for"
      monitor.status == :paused -> "Currently paused for"
      monitor.status == :inactive -> "Currently down for"
      monitor.status == :initializing -> "Initializing..."
      true -> ""
    end
  end

  defp time(%{last_incident: last_incident, monitor: monitor} = _assigns)
       when monitor.status == :active do
    from_time =
      if last_incident,
        do: last_incident.resolved_at,
        else: monitor.inserted_at

    from_time
    |> humanized_duration_in_seconds()
  end

  defp time(%{active_incident: active_incident, monitor: monitor} = _assigns)
       when monitor.status == :inactive do
    active_incident.occured_at
    |> humanized_duration_in_seconds()
  end

  defp time(%{monitor: monitor} = _assigns) when monitor.status == :paused do
    monitor.updated_at
    |> humanized_duration_in_seconds()
  end

  defp time(_assigns), do: ""

  defp start_timer() do
    :timer.send_interval(1000, self(), :tick)
  end
end
