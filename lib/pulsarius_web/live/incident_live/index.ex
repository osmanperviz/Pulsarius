defmodule PulsariusWeb.IncidentsLive.Index do
  use PulsariusWeb, :live_view

  alias Pulsarius.Incidents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
    # {:ok, assign(socket, :monitoring, Incidents.list_monitoring())}
  end

  def render(assigns) do
  end
end
