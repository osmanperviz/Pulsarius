defmodule PulsariusWeb.MonitorLive.MonitorWidget do
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
     |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
    <div class="box-item flex-grow-20">
      <div class="card box pt-2 w-100">
        <div class="card-body bcd justify-content-between">
          <div class="d-flex justify-content-between bordered-1">
            <div id="abc" class="d-flex">
              <div class="pulse m-2"></div>
              <div>
                <h6 class="m-1">
                  <%= link(@monitor.name,
                    to: Routes.monitor_show_path(@socket, :show, @monitor),
                    class: "text-capitalize text-white text-decoration-none"
                  ) %><br />
                  <span class="count-down"><%= display_status(@monitor.status) %> · 16h 51m</span>
                </h6>
              </div>
            </div>

            <div class="text-right d-flex">
              <p
                class="count-down mt-2"
                data-toggle="tooltip"
                data-placement="left"
                title="Cheched every 3 minute"
              >
                <i class="bi bi-broadcast"></i> 3m
              </p>

              <.dropdown monitor={@monitor} id={@id} socket={@socket} />
            </div>
          </div>
        </div>
        <div class=" card-body d-flex ">
          <.info_box value="181 ms" title="Avg. Response time" />
          <.info_box value="100%" title="Availability" />
          <.info_box value="0m" title="Downtime" />
        </div>
        <div id={@monitor.id} phx-hook="Chart"></div>
      </div>
    </div>
    """
  end

  defp display_status(status) do
    cond do
      status == :active -> "Up"
      status == :paused -> "Paused"
      status == :inactive -> "Down"
      status == :initializing -> "Initializing..."
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

  defp info_box(assigns) do
    ~H"""
    <div class="col-lg-4 text-center">
      <p class="mb-0"><%= @value %></p>
      <p class="count-down"><%= @title %></p>
    </div>
    """
  end

  defp dropdown(assigns) do
    ~H"""
    <div class="dropdown">
      <a class=" abc" data-bs-toggle="dropdown" type="button" aria-expanded="false" id={@id}>
        <i class="bi bi-three-dots icon-dots"></i>
      </a>
      <ul class="dropdown-menu dropdown-menu-end" aria-labelledby={@id}>
        <li>
          <a class="dropdown-item pb-1" href={Routes.monitor_edit_path(@socket, :edit, @monitor)}>
            <i class="bi bi-gear-wide-connected"></i>&nbsp; Configure
          </a>
        </li>
        <li><hr class="dropdown-divider" /></li>
        <li>
          <.pause_link monitor={@monitor} />
        </li>
        <li>
          <a class="dropdown-item pb-1" href="#" phx-click="send-test-alert">
            <i class="bi-exclamation-triangle bi-lg"></i>&nbsp; Send a test alert
          </a>
        </li>
        <li>
          <a class="dropdown-item" href={Routes.incidents_index_path(@socket, :index, @monitor.id)}>
            <i class="bi-shield-exclamation"></i>&nbsp; Incidents
          </a>
        </li>
        <li><hr class="dropdown-divider" /></li>
        <li><a class="dropdown-item" href="#"><i class="bi bi-trash"></i>&nbsp; Delete</a></li>
      </ul>
    </div>
    """
  end

  def pause_link(assigns) do
    ~H"""
    <%= if @monitor.status == :paused do %>
      <a
        class="dropdown-item pb-1"
        phx-click="unpause-monitoring"
        phx-value-monitor_id={@monitor.id}
        href="#"
      >
        <i class="bi bi-pause-circle"></i>&nbsp; Unpause
      </a>
    <% else %>
      <a
        class="dropdown-item pb-1"
        phx-click="pause-monitoring"
        phx-value-monitor_id={@monitor.id}
        href="#"
      >
        <i class="bi bi-pause-circle"></i>&nbsp; Pause
      </a>
    <% end %>
    """
  end
end
