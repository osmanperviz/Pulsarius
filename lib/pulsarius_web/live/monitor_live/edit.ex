defmodule PulsariusWeb.MonitorLive.Edit do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring

  @impl true
  def mount(params, _session, socket) do
    monitor =
      Monitoring.get_monitor!(params["id"])

    socket =
      socket
      |> assign(:monitor, monitor)

    {:ok, socket}
  end
end
