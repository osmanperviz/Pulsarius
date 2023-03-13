defmodule Pulsarius.EndpointChecker do
  @moduledoc """
  The actual process that monitors and ping web services
  """
  use GenServer

  alias Pulsarius.Monitoring
  alias Pulsarius.Monitoring.Monitor
  alias Pulsarius.Incidents

  require Logger

  @registry :endpoint_checker
  @topic "incidents"

  def start_link(monitor) do
    GenServer.start_link(
      __MODULE__,
      build_initial_state(monitor),
      name: via_tuple(monitor.id)
    )
  end

  @doc """
  In case monitoring is paused, we just spin process and wait further instructions, 
  monitoring should be manually unpause
  """
  def init(%{monitor: monitor} = state) when monitor.status == :paused do
    {:ok, state}
  end

  def init(state) do
    state
    |> schedule_first_check()
    |> then(&{:ok, &1})
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
    state = %{state | monitor: updated_monitor}
    schedule_check(state)

    {:reply, :ok, state}
  end

  def handle_info(:ping_endpoint, state) when state.monitor == :paused do
    {:noreply, state}
  end

  def handle_info(:ping_endpoint, state) do
    # start measuring response time
    state = %{state | start_measuring_response_time: System.monotonic_time(:millisecond)}

    ping_endpoint(state.monitor)
    |> handle_response(state)
    |> then(&schedule_check(&1))
    |> then(&{:noreply, &1})
  end

  defp schedule_check(%{monitor: monitor} = state) when monitor.status == :paused,
    do: state

  defp schedule_check(state) do
    frequency_check_in_ms = convert_to_ms(state.monitor.configuration.frequency_check_in_seconds)
    # Process.send_after(self(), :ping_endpoint, frequency_check_in_ms)
    Process.send_after(self(), :ping_endpoint, 4000)

    state
  end

  defp via_tuple(monitor_id) do
    {:via, Registry, {@registry, monitor_id}}
  end

  defp ping_endpoint(%{monitor: %Monitor{status: status}} = _state) when status == :paused,
    do: :ping_paused

  defp ping_endpoint(monitor),
    do: HTTPoison.get!(monitor.configuration.url_to_monitor)

  defp handle_response(:ping_paused, state), do: state

  defp handle_response(%HTTPoison.Response{status_code: 200} = response, state)
       when state.in_incident_mode == false do
    params = %{
      occured_at: DateTime.utc_now(),
      response_time_in_ms: measure_response_time(state.start_measuring_response_time)
    }

    Task.start(fn -> Monitoring.create_status_response(state.monitor, params) end)

    %{state | start_measuring_response_time: nil}
  end

  defp handle_response(%HTTPoison.Response{status_code: 200} = _response, state)
       when state.in_incident_mode == true do
    handle_incident(state)
  end

  defp handle_response(%HTTPoison.Response{status_code: _status_code} = _response, state)
       when state.in_incident_mode == false do
    {:ok, monitor} = Monitoring.update_monitor(state.monitor, %{status: :inactive})
    {:ok, incident} = Incidents.create_incident(monitor)

    Pulsarius.broadcast(@topic, {:incident_created, incident})

    # Pulsarius.broadcast("incidents", {:incident_created, %{monitor_id: "1cc2cc31-e0e3-4e9e-a013-b2144ce43b2c"}})

    %{
      state
      | monitor: monitor,
        incident: incident,
        in_incident_mode: true,
        start_measuring_response_time: nil
    }
  end

  defp handle_response(%HTTPoison.Response{status_code: _status_code} = _response, state)
       when state.in_incident_mode == true,
       do: state

  defp handle_incident(state) when state.number_of_success_retry == 3 do
    {:ok, incident} = Incidents.auto_resolve(state.incident)
    {:ok, monitor} = Monitoring.update_monitor(state.monitor, %{status: :active})

    Pulsarius.broadcast(@topic, {:incident_auto_resolved, incident})

    # Pulsarius.broadcast("incidents", {:incident_auto_resolved, %{monitor_id: "1cc2cc31-e0e3-4e9e-a013-b2144ce43b2c"}})

    %{
      state
      | monitor: monitor,
        incident: nil,
        number_of_success_retry: 0,
        in_incident_mode: false,
        start_measuring_response_time: nil
    }
  end

  defp handle_incident(state) when state.number_of_success_retry < 3 do
    %{state | number_of_success_retry: state.number_of_success_retry + 1}
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

  defp build_initial_state(%Monitor{active_incident: nil} = monitor) do
    %{
      monitor: monitor,
      in_incident_mode: false,
      incident: nil,
      number_of_success_retry: 0,
      start_measuring_response_time: nil
    }
  end

  defp build_initial_state(monitor) do
    %{
      monitor: monitor,
      in_incident_mode: true,
      incident: monitor.active_incident,
      number_of_success_retry: 0,
      start_measuring_response_time: nil
    }
  end

  defp measure_response_time(start_time) do
    System.monotonic_time(:millisecond) - start_time
  end

  defp convert_to_ms(frequency_check_in_seconds) do
    String.to_integer(frequency_check_in_seconds) * 1000
  end

  defp schedule_first_check(state) do
    Process.send_after(self(), :ping_endpoint, 500)
    state
  end
end
