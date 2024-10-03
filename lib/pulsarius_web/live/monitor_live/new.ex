defmodule PulsariusWeb.MonitorLive.New do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring.Monitor
  alias Pulsarius.Configurations.Configuration

  @impl true
  def mount(_params, _session, %{assigns: assigns} = socket) do
    monitor = %Monitor{configuration: %Configuration{}}

    socket =
      socket
      |> assign(:monitor, monitor)

    {:ok, socket}
  end
end
