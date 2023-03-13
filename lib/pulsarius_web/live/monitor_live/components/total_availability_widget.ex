defmodule PulsariusWeb.MonitorLive.TotalAvailabilityWidget do
  use PulsariusWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    start_timer()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:title, title(assigns.monitor))
     |> assign(:humanized_time, time(assigns))
     |> assign(:ticker_scheduled, true)}
  end

  def render(assigns) do
    ~H"""
    <div class="box-item flex-grow-100">
      <div class="card box pb-2 pt-2  w-100">
        <div class="card-body">
          <h6><span class="abc"><%= @title %></span></h6>
          <h6><%= @humanized_time %></h6>
        </div>
      </div>
    </div>
    """
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
      if last_incident && last_incident.resolved_at != nil,
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
    Process.send_after(self(), :update_availability_time, 10000)
    # :timer.send_interval(1000, self(), :update_availability_time)
  end
end
