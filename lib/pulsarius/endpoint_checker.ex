defmodule Pulsarius.EndpointChecker do
  use GenServer

  alias Pulsarius.Monitoring
  alias Pulsarius.Monitoring.Monitor

  @registry :endpoint_checker

  def start_link(monitor) do
    GenServer.start_link(
      __MODULE__,
      monitor,
      name: via_tuple(monitor.id)
    )
  end

  def init(state) do
    monitor =
      HTTPoison.get!(state.configuration.url_to_monitor)
      |> handle_response(state)

    schedule_work()

    {:ok, monitor}
  end

  def handle_info(:ping_endpoint, state) do
    monitor =
      HTTPoison.get!(state.configuration.url_to_monitor)
      |> handle_response(state)

    # Schedule work to be performed again
    schedule_work()

    {:noreply, monitor}
  end

  defp schedule_work() do
    Process.send_after(self(), :ping_endpoint, 1000)
  end

  defp via_tuple(monitor_id) do
    {:via, Registry, {@registry, monitor_id}}
  end

  defp handle_response(%HTTPoison.Response{status_code: status_code} = _response, monitor) do
    case status_code do
      200 ->
        dbg(monitor)
        {:ok, monitor} = set_monitor_state_to_active(monitor)
        monitor

      _ ->
        {:ok, monitor} = set_monitor_status_to_inactive(monitor)
        monitor
    end
  end

  defp set_monitor_state_to_active(%Monitor{status: status} = monitor)
       when status in [:initializing, :inactive],
       do: Monitoring.update_monitor(monitor, %{status: :active})

  defp set_monitor_state_to_active(monitor), do: {:ok, monitor}

  defp set_monitor_status_to_inactive(%Monitor{status: status} = monitor)
       when status in [:initializing, :active],
       do: Monitoring.update_monitor(monitor, %{status: :inactive})

  defp set_monitor_status_to_inactive(monitor),
    do: {:ok, monitor}
end
