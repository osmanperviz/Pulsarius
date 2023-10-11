defmodule PulsariusWeb.MonitorLive.MonitoringComponents do
  use PulsariusWeb, :component

  attr :name, :string, required: true

  def greetings(assigns) do
    ~H"""
    <h3><%= random_greeting(@name) %></h3>
    """
  end

  attr :monitor, Pulsarius.Monitoring.Monitor, required: true

  def header(assigns) do
    ~H"""
    <div class="mt-2">
      <.link
        href={Routes.monitor_index_path(PulsariusWeb.Endpoint, :index)}
        class="btn bg-transparent abc p-0"
      >
        <span class="bi-chevron-left"></span> Monitors
      </.link>
      <div class="col-lg-12 d-flex m-0 p-0">
        <div class={"#{get_class(@monitor)} mt-5"}></div>
        <div class="m-4">
          <h5 class="mt-2"><%= @monitor.name %></h5>
          <p>
            <span><%= monitor_status(@monitor) %></span>
            <span class="abc">
              ·  Checked every <%= display_frequency_check_in_seconds(
                @monitor.configuration.frequency_check_in_seconds
              ) %> minutes
            </span>
          </p>
        </div>
      </div>
      <div class="col-lg-12">
        <button type="button" class="btn  bg-transparent abc mr-4" phx-click="send-test-alert">
          <span class="bi-exclamation-triangle bi-lg"></span>&nbsp;Send test alert
        </button>
        <a
          href={Routes.incidents_index_path(PulsariusWeb.Endpoint, :index, @monitor.id)}
          role="button"
          class="btn bg-transparent abc mr-4"
        >
          <span class="bi-shield-exclamation"></span> Incidents
        </a>

        <button
          type="button"
          class="btn bg-transparent abc mr-4"
          phx-click={
            if @monitor.status == :active, do: "pause-monitoring", else: "unpause-monitoring"
          }
        >
          <span class="bi bi-pause-circle "></span>&nbsp;<%= pause_button_title(@monitor) %>
        </button>
        <a
          role="button"
          class="btn bg-transparent abc mr-4"
          href={Routes.monitor_edit_path(PulsariusWeb.Endpoint, :edit, @monitor)}
        >
          <span class="bi-gear"></span>&nbsp;Configure
        </a>
      </div>
    </div>
    """
  end

  attr :selected_period, :string, required: true

  def chart(assigns) do
    ~H"""
    <div class="col-lg-12">
      <div class="card box pb-1 pt-2 mt-3">
        <div class="card-body flex-column d-flex" style="max-height: 500px">
          <div class="btn-group btn-group-sm align-self-end">
            <button
              type="button"
              phx-click="change-date-range"
              phx-value-period={:day}
              class={"btn btn-outline-secondary #{active_period("day", @selected_period)}"}
            >
              Day
            </button>
            <button
              type="button"
              phx-click="change-date-range"
              phx-value-period={:week}
              class={"btn btn-outline-secondary #{active_period("week", @selected_period)}"}
            >
              Week
            </button>
            <button
              type="button"
              phx-click="change-date-range"
              phx-value-period={:month}
              class={"btn btn-outline-secondary #{active_period("month", @selected_period)}"}
            >
              Month
            </button>
          </div>
          <div id="myChart" phx-hook="DatailsChart" phx-update="ignore" style="min-height: 300px">
          </div>
          <script src="https://cdn.jsdelivr.net/npm/chart.js">
          </script>
        </div>
      </div>
    </div>
    """
  end

  def table(assigns) do
    ~H"""
    <div class="col-lg-12">
      <div class="card box pb-5 pt-2 mt-3">
        <div class="card-body table-responsive">
          <table class="table table-borderless table-hover p-0 ">
            <thead style="ml-1">
              <tr>
                <th class="abc">Time period</th>
                <th class="abc">Availability</th>
                <th class="abc">Downtime</th>
                <th class="abc">Incidents</th>
                <th class="abc">Longest incident</th>
              </tr>
            </thead>
            <tbody class="ml-1">
              <tr>
                <td class="table-text">Today</td>
                <td class="table-text">
                  <%= @avalability_statistics.todays_statistics.total_avalability_in_percentage %>%
                </td>
                <td class="table-text">
                  <%= display_humanized_duration(
                    @avalability_statistics.todays_statistics.total_down_time_in_minutes
                  ) %>
                </td>
                <td class="table-text">
                  <%= @avalability_statistics.todays_statistics.number_of_incidents %>
                </td>
                <td class="table-text">
                  <%= display_humanized_duration(
                    @avalability_statistics.todays_statistics.longest_incident_duration_in_minutes
                  ) %>
                </td>
              </tr>
              <tr>
                <td class="table-text">Last 7 days</td>
                <td class="table-text">
                  <%= @avalability_statistics.weekly_statistics.total_avalability_in_percentage %>%
                </td>
                <td class="table-text">
                  <%= display_humanized_duration(
                    @avalability_statistics.weekly_statistics.total_down_time_in_minutes
                  ) %>
                </td>
                <td class="table-text">
                  <%= @avalability_statistics.weekly_statistics.number_of_incidents %>
                </td>
                <td class="table-text">
                  <%= display_humanized_duration(
                    @avalability_statistics.weekly_statistics.longest_incident_duration_in_minutes
                  ) %>
                </td>
              </tr>
              <tr>
                <td class="table-text">Last 30 days</td>
                <td class="table-text">
                  <%= @avalability_statistics.monthly_statistics.total_avalability_in_percentage %>%
                </td>
                <td class="table-text">
                  <%= display_humanized_duration(
                    @avalability_statistics.monthly_statistics.total_down_time_in_minutes
                  ) %>
                </td>
                <td class="table-text">
                  <%= @avalability_statistics.monthly_statistics.number_of_incidents %>
                </td>
                <td class="table-text">
                  <%= display_humanized_duration(
                    @avalability_statistics.monthly_statistics.longest_incident_duration_in_minutes
                  ) %>
                </td>
              </tr>
              <tr>
                <td class="table-text">Last 365 days</td>
                <td class="table-text">
                  <%= @avalability_statistics.annual_statistics.total_avalability_in_percentage %>%
                </td>
                <td class="table-text">
                  <%= display_humanized_duration(
                    @avalability_statistics.annual_statistics.total_down_time_in_minutes
                  ) %>
                </td>
                <td class="table-text">
                  <%= @avalability_statistics.annual_statistics.number_of_incidents %>
                </td>
                <td class="table-text">
                  <%= display_humanized_duration(
                    @avalability_statistics.annual_statistics.longest_incident_duration_in_minutes
                  ) %>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  def incident_widget(assigns) do
    ~H"""
    <div class="box-item flex-grow-100">
      <div class="card box pb-2 pt-2 w-100">
        <div class="card-body">
          <div class="d-flex justify-content-between">
            <h6><span class="abc p-0"><%= @title %></span></h6>
            <%= if @active_incident do %>
              <a
                class="btn btn-sm bg-transparent gray-color p-0"
                href={
                  Routes.incidents_show_path(
                    PulsariusWeb.Endpoint,
                    :show,
                    @active_incident.monitor_id,
                    @active_incident.id
                  )
                }
              >
                <span class="bi bi-shield-fill-exclamation fs-6  text-danger p-0"></span>
                Ongoing incident <span class="bi-chevron-right"></span>
              </a>
            <% end %>
          </div>
          <h6><%= @value %></h6>
        </div>
      </div>
    </div>
    """
  end

  defp box(assigns) do
    ~H"""
    <div class="card box pb-2 pt-2 w-100">
      <div class="card-body pt-4 pb-4"></div>
    </div>
    """
  end

  defp pause_button_title(monitor) when monitor.status == :paused, do: "Unpause this monitor"
  defp pause_button_title(monitor), do: "Pause this monitor"

  def monitor_status(monitor) do
    cond do
      monitor.status == :active ->
        "Up"

      monitor.status == :paused ->
        "Paused"

      monitor.status == :inactive ->
        "Down"

      true ->
        "Unknown"
    end
  end

  def display_frequency_check_in_seconds(frequency) do
    (String.to_integer(frequency) / 60) |> round()
  end

  defp active_period(period, selected_period) do
    if period == selected_period, do: "active", else: ""
  end

  defp display_humanized_duration(0) do
    "-"
  end

  defp display_humanized_duration(duration_in_minutes) do
    Timex.format_duration(Timex.Duration.from_minutes(duration_in_minutes), :humanized)
  end

  def random_greeting(name) do
    greetings = [
      {:question, "How has your day been so far,"},
      {:question, "How is it going,"},
      {:statment, "Greetings,"},
      {:question, "How are you today,"},
      {:statment, "Have a great day,"}
    ]

    {type, greeting} = Enum.random(greetings)

    mark = if type == :question, do: "?", else: "!"
    "#{greeting} #{name}#{mark}"
  end

  defp get_class(monitor) do
    cond do
      monitor.status == :active -> "pulse-success"
      monitor.status == :paused -> "pulse-paused"
      monitor.status == :inactive -> "pulse-inactive"
      true -> "pulse-inactive"
    end
  end
end
