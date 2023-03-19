defmodule PulsariusWeb.MonitorLive.MonitorWidget do
  use PulsariusWeb, :live_component
  use Timex

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> push_event("response_time", %{
       response_time: build_response_time(assigns.monitor.status_response)
     })}
  end

  def render(assigns) do
    ~H"""
    <div class="box-item flex-grow-20">
      <div class="card box pt-2 w-100">
        <div class="card-body bcd justify-content-between">
          <div class="d-flex justify-content-between bordered-1">
            <div id="abc" class="d-flex">
              <div class={" #{get_class(@monitor)} m-2"}></div>
              <div>
                <h6 class="m-1">
                  <%= link(@monitor.name,
                    to: Routes.monitor_show_path(@socket, :show, @monitor),
                    class: "text-capitalize text-white text-decoration-none"
                  ) %><br />
                  <span class="count-down">
                    <%= display_status(@monitor.status) %> · <%= time(@monitor) %>
                  </span>
                </h6>
              </div>
            </div>
            <div class="col-lg-3 text-right d-flex justify-content-between">
              <.certificate_info monitor={@monitor} />
              <.frequency_check_info monitor={@monitor} />
              <.dropdown monitor={@monitor} id={@id} socket={@socket} />
            </div>
          </div>
        </div>
        <div class=" card-body d-flex ">
          <.statistics_info
            value={"#{@monitor.statistics.average_response_time}ms"}
            title="Avg. Response time"
          />
          <.statistics_info
            value={"#{@monitor.statistics.total_avalability_in_percentage}%"}
            title="Availability"
          />
          <.statistics_info
            value={"#{@monitor.statistics.total_down_time_in_minutes}m"}
            title="Downtime"
          />
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

  defp time(monitor)
       when monitor.status == :active do
    last_incident = List.last(monitor.incidents)

    from_time =
      if last_incident && last_incident.resolved_at != nil,
        do: last_incident.resolved_at,
        else: monitor.updated_at

    from_time
    |> humanized_duration_in_hours()
  end

  defp time(monitor)
       when monitor.status == :inactive do
    monitor.active_incident.occured_at
    |> humanized_duration_in_minutes()
  end

  defp time(monitor) when monitor.status == :paused do
    monitor.updated_at
    |> humanized_duration_in_hours()
  end

  defp time(_assigns), do: ""

  defp statistics_info(assigns) do
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

  defp frequency_check_info(assigns) do
    ~H"""
    <a
      href={Routes.monitor_edit_path(PulsariusWeb.Endpoint, :edit, @monitor)}
      class="count-down mt-2 text-decoration-none"
      data-bs-toggle="tooltip"
      data-bs-placement="left"
      title={"Cheched every #{display_frequency_check_in_seconds(@monitor.configuration.frequency_check_in_seconds)} minute"}
    >
      <i class="bi bi-broadcast"></i>
      <%= display_frequency_check_in_seconds(@monitor.configuration.frequency_check_in_seconds) %>m
    </a>
    """
  end

  defp certificate_info(assigns) do
    ~H"""
    <i
      data-bs-toggle="tooltip"
      data-bs-placement="top"
      title={"Certificate expires in #{calculate_expiration_date(@monitor)}"}
      class="bi bi-award-fill mt-1"
    >
    </i>
    """
  end

  defp display_frequency_check_in_seconds(frequency) do
    (String.to_integer(frequency) / 60) |> round()
  end

  def build_response_time(response_time) do
    Enum.filter(response_time, fn rt ->
      rt.occured_at in todays_range
    end)
    |> Enum.sort_by(&Map.fetch!(&1, :inserted_at), :desc)
    |> Enum.take(80)
    |> Enum.reverse()
    |> Enum.map(fn a ->
      %{x: NaiveDateTime.to_time(a.occured_at) |> Time.to_string(), y: a.response_time_in_ms}
    end)
  end

  defp todays_range() do
    from = Timex.now() |> Timex.beginning_of_day()
    until = Timex.now() |> Timex.end_of_day()

    Interval.new(from: from, until: until)
  end

  defp calculate_expiration_date(monitor) do
    expiration_date = monitor.ssl_expiry_date
    from = Timex.now() |> Timex.beginning_of_day()


    Interval.new(from: from, until: expiration_date)
    |> Interval.duration(:months)
    |> case do
      0 -> "Less than an mounth (#{Calendar.strftime(expiration_date, "%A.%m.%Y")})"
      result -> 
      "#{result} mounths (#{Calendar.strftime(expiration_date, "%b %d, %Y")})"
    end
  end

  defp get_class(monitor) do
    cond do
      monitor.status == :active -> "pulse-success"
      monitor.status == :paused -> "pulse-paused"
    end
  end
end
