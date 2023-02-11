defmodule PulsariusWeb.MonitorLive.New do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring
  alias Pulsarius.Monitoring.Monitor
  alias Pulsarius.Configurations.Configuration

  @impl true
  def mount(_params, _session, socket) do
    monitor = %Monitor{configuration: %Configuration{}}
    changeset = Monitoring.change_monitor(monitor)

    {:ok, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"monitor" => monitor_params}, socket) do
    # TODO: convert frequency_check from minutes to milliseconds or
    # deliver that already from server to dropdow than no need to convertion

    case Monitoring.create_monitor(socket.assigns.account, monitor_params) do
      {:ok, monitor} ->
        monitor = Pulsarius.Repo.preload(monitor, [:active_incident])
        Pulsarius.EndpointDynamicSupervisor.start_monitoring(monitor)
        dbg(monitor)

        {:noreply,
         socket
         |> put_flash(:info, "Monitor created successfully")
         |> push_redirect(to: Routes.monitor_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
