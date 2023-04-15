defmodule PulsariusWeb.MonitorLive.FormComponent do
  use PulsariusWeb, :live_component

  alias Pulsarius.Monitoring
  alias Pulsarius.Configurations.Configuration

  @impl true
  def update(%{monitor: monitor} = assigns, socket) do
    changeset = Monitoring.change_monitor(monitor)

    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:show_http_status_code, false)
      |> assign(:show_keyword_input, false)
      |> assign(:show_domain_alert_configuration, false)
      |> assign(:show_ssl_alert_configuration, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"monitor" => monitor_params}, socket) do
    changeset =
      socket.assigns.monitor
      |> Monitoring.change_monitor(monitor_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "alert-rule-changed",
        %{
          "monitor" => %{
            "configuration" => %{"alert_rule" => alert_rule}
          }
        },
        socket
      ) do
    socket =
      cond do
        alert_rule == "does_not_contain_keyword" or alert_rule == "contain_keyword" ->
          socket
          |> assign(:show_http_status_code, false)
          |> assign(:show_keyword_input, true)

        alert_rule == "http_status_other_than" ->
          socket
          |> assign(:show_http_status_code, true)
          |> assign(:show_keyword_input, false)

        true ->
          socket
          |> assign(:show_http_status_code, false)
          |> assign(:show_keyword_input, false)
      end

    {:noreply, socket}
  end

  def handle_event("save", %{"monitor" => monitor_params}, socket) do
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
         |> push_redirect(to: Routes.monitor_index_path(PulsariusWeb.Endpoint, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_monitor(socket, :new, monitor_params) do
    case Monitoring.create_monitor(socket.assigns.account, monitor_params) do
      {:ok, monitor} ->
        monitor = Pulsarius.Repo.preload(monitor, [:active_incident])

        if Monitor.ssl_check?(monitor) do
          Task.start(fn -> Monitoring.set_ssl_expiry(monitor) end)
        end

        Pulsarius.EndpointDynamicSupervisor.start_monitoring(monitor)

        {:noreply,
         socket
         |> put_flash(:info, "Monitor created successfully")
         |> push_redirect(to: Routes.monitor_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_monitor(socket, :edit, monitor_params) do
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
