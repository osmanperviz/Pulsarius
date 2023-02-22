defmodule PulsariusWeb.MonitorLive.CheckedAtWidget do
  use Phoenix.LiveView,
    container: {:div, class: "box-item right"}

  import PulsariusWeb.LiveHelpers

  alias Pulsarius.Monitoring

  @impl true
  def mount(:not_mounted_at_router, %{"monitor" => monitor}, socket) do
    most_recent_status_response = Monitoring.get_most_recent_status_response!(monitor.id)
    humanized_time = time(most_recent_status_response, monitor)

    start_timer()

    {:ok,
     socket
     |> assign(:monitor, monitor)
     |> assign(:title, "Last checked at")
     |> assign(:most_recent_status_response, most_recent_status_response)
     |> assign(:humanized_time, humanized_time)}
  end

  def render(assigns) do
    ~H"""
    <div class="w-100">
      <div class="card box pb-2 pt-2  w-100">
        <div class="card-body">
          <h6><span class="abc"><%= assigns.title %></span></h6>
          <h6><%= @humanized_time %> ago</h6>
        </div>
      </div>
    </div>
    """
  end

  def handle_info(:tick, %{assigns: assigns} = socket) do
    humanized_time = time(assigns.most_recent_status_response, assigns.monitor)

    {:noreply, assign(socket, :humanized_time, humanized_time)}
  end

  defp time(last_status_response, monitor)
       when monitor.status == :active do
    last_status_response.occured_at
    |> humanized_duration_in_seconds
  end

  defp time(_last_status_response, _monitor), do: ""

  defp start_timer() do
    :timer.send_interval(1000, self(), :tick)
  end
end
