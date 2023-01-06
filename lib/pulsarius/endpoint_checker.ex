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
    {:ok, monitor} =
      HTTPoison.get!(state.configuration.url_to_monitor)
      |> handle_response(state)

    schedule_check()

    {:ok, monitor}
  end

  def handle_info(:ping_endpoint, state) do
    {:ok, monitor} =
      HTTPoison.get!(state.configuration.url_to_monitor)
      |> handle_response(state)

    # Schedule work to be performed again
    schedule_check()

    {:noreply, monitor}
  end

  defp schedule_check() do
    Process.send_after(self(), :ping_endpoint, 1000)
  end

  defp via_tuple(monitor_id) do
    {:via, Registry, {@registry, monitor_id}}
  end

  defp handle_response(%HTTPoison.Response{status_code: 200} = _response, monitor) do
    Monitoring.update_monitor(monitor, %{status: :active})
  end

  defp handle_response(%HTTPoison.Response{status_code: _status_code} = _response, monitor) do
    Monitoring.update_monitor(monitor, %{status: :inactive})
  end
end
