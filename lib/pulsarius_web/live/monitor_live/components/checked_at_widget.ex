defmodule PulsariusWeb.MonitorLive.CheckedAtWidget do
  use PulsariusWeb, :live_component

  @impl true
  def mount(socket) do
    # start_timer()
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    start_timer()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:title, "Last checked at")
     |> assign(:humanized_time, time(assigns))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="box-item flex-grow-100">
      <div class="card box pb-2 pt-2  w-100">
        <div class="card-body">
          <h6><span class="abc p-0"><%= @title %></span></h6>
          <%= if @humanized_time != nil  do %>
            <h6><%= @humanized_time %> ago</h6>
          <% else %>
            -
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp time(%{last_status_response: last_status_response, monitor: monitor} = _assigns)
       when monitor.status == :active and last_status_response != nil do
    last_status_response.occured_at
    |> humanized_duration_in_seconds
  end

  defp time(_assings), do: nil

  defp start_timer() do
    # :timer.send_interval(1000, self(), :tick)
    Process.send_after(self(), :tick, 1000)
  end
end
