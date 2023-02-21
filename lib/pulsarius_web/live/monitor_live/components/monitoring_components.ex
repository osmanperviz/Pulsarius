defmodule PulsariusWeb.MonitorLive.MonitoringComponents do
  use PulsariusWeb, :component

  attr :monitor, Pulsarius.Monitoring.Monitor, required: true

  def header(assigns) do
    ~H"""
    <div>
      <.link href={Routes.monitor_index_path(@socket, :index)} class="btn bg-transparent abc">
        <span class="bi-chevron-left"></span> Monitor
      </.link>
      <div class="col-lg-12 d-flex">
        <div class="pulse"></div>
        <div>
          <h5 class="mt-4"><%= @monitor.name %></h5>
          <p>
            <%= monitor_status(@monitor) %>
            <span class="abc">
              ·  Checked every <%= display_frequency_check_in_seconds(
                @monitor.configuration.frequency_check_in_seconds
              ) %> minutes
            </span>
          </p>
        </div>
      </div>
      <div class="col-lg-12 mt-5">
        <button type="button" class="btn  bg-transparent abc mr-4" phx-click="send-test-alert">
          <span class="bi-exclamation-triangle bi-lg"></span>&nbsp;Send test alert
        </button>
        <a
          href={Routes.incidents_index_path(@socket, :index, @monitor.id)}
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
          href={Routes.monitor_edit_path(@socket, :edit, @monitor)}
        >
          <span class="bi-gear"></span>&nbsp;Configure
        </a>
      </div>
    </div>
    """
  end

  attr :last_item, :boolean, default: false
  attr :title, :string, required: true
  attr :value, :string, required: true

  def box_item(assigns) do
    ~H"""
    <div class={box_item_css(@last_item)}>
      <div class="card box pb-2 pt-2 w-100">
        <div class="card-body">
          <h6><span class="abc"><%= @title %></span></h6>
          <h6><%= @value %></h6>
        </div>
      </div>
    </div>
    """
  end

  def chart(assigns) do
    ~H"""
    <div class="col-lg-12">
      <div class="card box pb-5 pt-2 mt-3">
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
          <canvas id="myChart" phx-hook="Chart" phx-update="ignore" style="min-height: 300px">
          </canvas>
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
        <div class="card-body">
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

  defp pause_button_title(monitor) when monitor.status == :active, do: "Pause this monitor"

  defp pause_button_title(monitor), do: "Unpause this monitor"

  defp monitor_status(monitor) when monitor.status == :active,
    do: "Up"

  defp monitor_status(monitor) when monitor.status == :paused,
    do: "Paused"

  defp monitor_status(_monitor), do: "Down"

  defp box_item_css(false), do: "box-item right"
  defp box_item_css(true), do: "box-item"

  def display_frequency_check_in_seconds(frequency) do
    (String.to_integer(frequency) / 60) |> round()
  end

  defp active_period(period, selected_period) do
    if period == selected_period, do: "active", else: ""
  end

  defp display_humanized_duration(duration_in_minutes) do
    duration_in_seconds = duration_in_minutes * 60

    Timex.format_duration(
      %Timex.Duration{seconds: duration_in_seconds, megaseconds: 0, microseconds: 0},
      :humanized
    )
  end
end
