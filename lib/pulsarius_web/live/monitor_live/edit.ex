defmodule PulsariusWeb.MonitorLive.Edit do
  use PulsariusWeb, :live_view

  alias Pulsarius.Monitoring
  alias Pulsarius.Configurations.Configuration

  @impl true
  def mount(params, _session, socket) do
    monitor = Monitoring.get_monitor!(params["id"])
    changeset = Monitoring.change_monitor(monitor)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:monitor, monitor)

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"monitor" => monitor_params}, socket) do
    IO.inspect(monitor_params)

    case Monitoring.update_monitor(socket.assigns.monitor, monitor_params) do
      {:ok, monitor} ->
        # update related running monitor process
        Pulsarius.EndpointChecker.update_state(monitor)

        {:noreply,
         socket
         |> put_flash(:info, "Monitor updated successfully")
         |> push_redirect(to: Routes.monitor_show_path(socket, :show, monitor))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
