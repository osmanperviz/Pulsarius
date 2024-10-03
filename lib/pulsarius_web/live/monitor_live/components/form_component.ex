defmodule PulsariusWeb.MonitorLive.FormComponent do
  use PulsariusWeb, :live_component

  alias Pulsarius.Monitoring
  alias Pulsarius.Monitoring.Monitor
  alias Pulsarius.Configurations.Configuration
  alias Pulsarius.Accounts.Policy, as: AccountsPolicy

  @impl true
  def update(%{monitor: monitor} = assigns, socket) do
    changeset = Monitoring.change_monitor(monitor)
    frequency_check_values = frequency_check_values(assigns.account.type)

    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:show_http_status_code, show_http_status_code(monitor))
      |> assign(:show_keyword_input, show_keyword_input(monitor))
      |> assign(:show_domain_alert_configuration, false)
      |> assign(:show_ssl_alert_configuration, false)
      |> assign(:frequency_check_values, frequency_check_values)

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
        %{"monitor" => %{"configuration" => %{"alert_rule" => alert_rule} = monitor_params}},
        socket
      ) do
    show_config =
      case alert_rule do
        "does_not_contain_keyword" ->
          {:keyword_input, true}

        "contain_keyword" ->
          {:keyword_input, true}

        "http_status_other_than" ->
          {:http_status_code, true}

        _ ->
          :none
      end

    changes = %{
      show_http_status_code: show_config == {:http_status_code, true},
      show_keyword_input: show_config == {:keyword_input, true}
    }

    socket =
      socket
      |> assign(:changeset, Monitoring.change_monitor(socket.assigns.monitor, monitor_params))
      |> assign(changes)

    {:noreply, socket}
  end

  def handle_event("save", %{"monitor" => monitor_params}, socket) do
    case AccountsPolicy.can?(socket.assigns.account, :save_monitor) do
      true ->
        save_monitor(socket, socket.assigns.action, monitor_params)

      false ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "You have reached the maximum allowed monitors. Please update your plan."
         )
         |> push_patch(to: Routes.monitor_new_path(socket, :new))}
    end
  end

  defp save_monitor(socket, :edit, monitor_params) do
    case Monitoring.update_monitor(socket.assigns.monitor, monitor_params) do
      {:ok, monitor} ->
        # update related running monitor process
        Pulsarius.UrlMonitor.update_state(monitor)

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
        Pulsarius.UrlMonitor.update_state(monitor)

        {:noreply,
         socket
         |> put_flash(:info, "Monitor updated successfully")
         |> push_redirect(to: Routes.monitor_show_path(socket, :show, monitor))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp frequency_check_values(account_type) do
    frequency_check_policy = Application.get_env(:pulsarius, :frequency_check_policy)
    frequency_check_policy[account_type]
  end

  defp show_http_status_code(monitor) do
    monitor.configuration.alert_rule == :http_status_other_than
  end

  defp show_keyword_input(monitor) do
    monitor.configuration.alert_rule in [:does_not_contain_keyword, :contain_keyword]
  end
end
