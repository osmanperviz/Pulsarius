defmodule PulsariusWeb.MonitorLive.MonitoringComponents do
  use PulsariusWeb, :component

  def header(assigns) do
    ~H"""
    <div>
      <.link href="#" class="text-decoration-none abc"><i class="bi-chevron-left"></i> Monitor</.link>
      <div class="col-lg-12 header">
        <h3 class="mt-4"><%= @monitor.name %></h3>
        <p class=""><%= monitor_status(@monitor) %>  ·  Checked every 2 minutes</p>
      </div>
      <div class="col-lg-12 mt-5">
        <button type="button" class="btn  bg-transparent abc mr-4" phx-click="send-test-alert">
          <span class="bi-exclamation-triangle bi-lg"></span>&nbsp;Send test alert
        </button>
        <button type="button" class="btn bg-transparent abc mr-4">
          <span class="bi-shield-exclamation"></span> Incidents
        </button>
        <button type="button" class="btn bg-transparent abc mr-4"  phx-click={if @monitor.status == :active, do:  "pause-monitoring", else: "unpause-monitoring"}>
          <span class="bi bi-pause-circle "></span>&nbsp;<%= pause_button_title(@monitor)%>
        </button>
        <button type="button" class="btn bg-transparent abc mr-4">
          <span class="bi-gear"></span>&nbsp;Configure
        </button>
      </div>
    </div>
    """
  end

  def box_item(assigns) do
    ~H"""
    <div class="box-item right">
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
        <div class="card-body" style="max-height: 300px">
          <canvas id="myChart"></canvas>
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
        <div class="card-body p-0">
          <table class="table table-borderless table-hover p-0 ">
            <thead style="ml-1">
              <tr>
                <th class="abc">Time period</th>
                <th class="abc">Availability</th>
                <th class="abc">Downtime</th>
                <th class="abc">Incidents</th>
                <th class="abc">Longest incident</th>
                <th class="abc">Avg. incident</th>
              </tr>
            </thead>
            <tbody class="ml-1">
              <tr>
                <td class="text-white">Today</td>
                <td class="text-white">100.0000%</td>
                <td class="text-white">none</td>
                <td class="text-white">5</td>
                <td class="text-white">none</td>
                <td class="text-white">none</td>
              </tr>
              <tr>
                <td class="text-white">Last Week</td>
                <td class="text-white">100.0000%</td>
                <td class="text-white">none</td>
                <td class="text-white">5</td>
                <td class="text-white">none</td>
                <td class="text-white">none</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp pause_button_title(monitor) when monitor.status == :active, do:
    "Pause this monitor"

  defp pause_button_title(monitor), do:
    "Unpause this monitor"

  defp monitor_status(monitor) when monitor.status == :active, 
    do: "Up"

  defp monitor_status(monitor) when monitor.status == :paused, 
    do: "Paused"

end
