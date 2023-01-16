defmodule Pulsarius.EndpointChecker do
  @moduledoc """
  The actual process that monitors and ping web services
  """
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

  @doc """
  In case monitoring is paused, we just spin process and wait further instructions, 
  monitoring should be manually unpause
  """
  def init(%Monitor{status: status} = monitor) when status == "paused" do
    {:ok, monitor}
  end

  def init(monitor) do
    {:ok, monitor} =
      HTTPoison.get!(state.configuration.url_to_monitor)
      |> handle_response(state)

    schedule_check(monitor)

    {:ok, monitor}
  end

  ## Public functions

  @spec update_state(Monitor.t()) :: :ok | {:error, :unable_to_locate_endpoint_checker}
  def update_state(monitor) do
    call_endpoint_checker(monitor, {:update_state, monitor})
  end

  @spec stop_monitoring(Monitor.t()) :: :ok | System.stacktrace()
  def stop_monitoring(monitor) do
    GenServer.stop(via_tuple(monitor.id))
  end

  ## Callbacks

  def handle_call({:update_state, updated_monitor}, _params, state) do
    schedule_check(updated_monitor)

    {:reply, :ok, updated_monitor}
  end

  def handle_info(:ping_endpoint, monitor) do
    {:ok, monitor} =
      HTTPoison.get!(monitor.configuration.url_to_monitor)
      |> handle_response(monitor)

    # Schedule work to be performed again
    schedule_check(monitor)

    {:noreply, monitor}
  end

  defp schedule_check(%Monitor{status: status} = monitor) when status == "paused",
    do: :ok

  defp schedule_check(monitor) do
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

  defp call_endpoint_checker(monitor, action) do
    case Registry.lookup(@registry, monitor.id) do
      [{pid, _}] ->
        GenServer.call(pid, action)

      _ ->
        Logger.warn("Unable to locate endpoint checker assigned to #{monitor.id}")
        {:error, :unable_to_locate_endpoint_checker}
    end
  end
end
