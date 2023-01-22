defmodule PulsariusWeb.MonitorLive.FormComponent do
  use PulsariusWeb, :live_component

  alias Pulsarius.Monitoring

  @impl true
  def update(%{monitor: monitor} = assigns, socket) do
    changeset = Monitoring.change_monitor(monitor)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"monitor" => monitor_params}, socket) do
    changeset =
      socket.assigns.monitor
      |> Monitoring.change_monitor(monitor_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"monitor" => monitor_params}, socket) do
    # TODO: convert frequency_check from minutes to milliseconds or
    # deliver that already from server to dropdow than no need to convertion
    save_monitor(socket, socket.assigns.action, monitor_params)
  end

  defp save_monitor(socket, :edit, monitor_params) do
    case Monitoring.update_monitor(socket.assigns.monitor, monitor_params) do
      {:ok, monitor} ->
        # update related running monitor process
        Pulsarius.EndpointChecker.update_state(monitor)

        {:noreply,
         socket
         |> put_flash(:info, "Monitor updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_monitor(socket, :new, monitor_params) do
    case Monitoring.create_monitor(monitor_params) do
      {:ok, monitor} ->
        monitor = Pulsarius.Repo.preload(monitor, [:active_incident])
        Pulsarius.EndpointDynamicSupervisor.start_monitoring(monitor)

        {:noreply,
         socket
         |> put_flash(:info, "Monitor created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
