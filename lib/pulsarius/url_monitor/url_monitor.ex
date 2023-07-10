defmodule Pulsarius.UrlMonitor do
  @moduledoc """
  The actual process that monitors and ping web services
  """
  use GenServer

  alias Pulsarius.Monitoring
  alias Pulsarius.Monitoring.Monitor
  alias Pulsarius.Incidents
  alias Pulsarius.Incidents.Screenshot
  alias Pulsarius.UrlMonitor.{HttpResponseHandler, UrlMonitorApi}

  require Logger

  @registry :url_monitor
  @incidents_topic "incidents"
  @monitor_topic "monitor:"

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
    state = %{state | monitor: updated_monitor, strategy: build_strategy(updated_monitor)}

    schedule_check(state)

    {:reply, :ok, state}
  end

  def handle_info(:check, state) when state.monitor == :paused do
    {:noreply, state}
  end

  @spec handle_info(atom(), map()) :: {:noreply, map()}
  def handle_info(:check, state) do
    # start measuring response time
    state = %{state | start_measuring_response_time: System.monotonic_time(:millisecond)}

    case UrlMonitorApi.send_request(state.monitor.configuration.url_to_monitor) do
      {:ok, response} ->
        case HttpResponseHandler.handle_response(response, state.strategy) do
          :available ->
            {:noreply, handle_available(state)}

          :unavailable ->
            {:noreply, handle_unavailable(state, response)}
        end

      {:error, reason} ->
        Logger.error("Something went wrong with HTTTP request: #{inspect(reason)}")
        {:norenply, schedule_check(state)}
    end
  end

  defp schedule_check(%{monitor: monitor} = state) when monitor.status == :paused,
    do: state

  defp schedule_check(state) do
    frequency_check_in_ms = convert_to_ms(state.monitor.configuration.frequency_check_in_seconds)

    Process.send_after(self(), :check, frequency_check_in_ms)

    state
  end

  defp via_tuple(monitor_id) do
    {:via, Registry, {@registry, monitor_id}}
  end

  defp check(%{monitor: %Monitor{status: status}} = _state) when status == :paused,
    do: :ping_paused

  @doc """
  If the bot is not in incident mode and the previous request was successful,
  this function schedules a check and returns `:noreply` with state.

  ## Parameters
  - `state`: A map representing the state of the bot.

  ## Returns
  - A tuple with `:noreply` and state.

  ## Examples

      iex> handle_available(%{in_incident_mode: false})
      {:noreply, state}
  """
  defp handle_available(%{in_incident_mode: false} = state) do
    state
    |> save_status_response()
    |> then(&schedule_check/1)
  end

  @doc """
  If the bot is in incident mode and receives a successful response, it schedules a check
  and returns `:noreply` with the updated state.

  If there have been at least 3 consecutive successful requests while in incident mode,
  this function will notify the customer that the service has recovered, set `in_incident_mode` to `false`,
  and return `:noreply` with the updated state.

  ## Parameters
  - `state`: A map representing the state of the bot.

  ## Returns
  - A tuple with `:noreply` and the updated state.

  ## Examples

      iex> handle_available(%{in_incident_mode: true, number_of_success_retry: 2})
      {:noreply, %{in_incident_mode: true, number_of_success_retry: 3}

      iex> handle_available(%{in_incident_mode: true, number_of_success_retry: 3})
      {:noreply, %{in_incident_mode: false, number_of_success_retry: 0}}
  """
  defp handle_available(%{in_incident_mode: true} = state) do
    state
    |> retry_or_notify_available()
  end

  @doc """
   If the bot is not incident mode and receives a error response,
  it's updates the monitor status to "inactive", creates a new incident, and broadcasts a message
  about the incident creation to a specified topic.

  Sets `in_incident_mode` to `true`, sets `start_measuring_response_time` to `nil`,
  and returns the updated state.

  ## Parameters
  - `state`: A map representing the state of the bot.
  - `response`: A HTTPoison.Response struct, representing response returned from monitored URL

  ## Returns
  - The updated state.

  ## Examples

      iex> handle_unavailable(%{in_incident_mode: false, monitor: %{id: 1, status: :active}}, response)
      %{in_incident_mode: true,
        incident: %{id: 2, monitor_id: 1, status: :created},
        monitor: %{id: 1, status: :inactive},
        start_measuring_response_time: nil}
  """
  def handle_unavailable(%{in_incident_mode: false, monitor: monitor} = state, response) do
    state
    |> retry_or_notify_unavailable(response)
  end

  @doc """
  If the bot is already in incident mode and receives an error response, it will ignore the response
  and return the current state.

  ## Parameters
  - `state`: A map representing the state of the bot.
  - `response`: A HTTPoison.Response struct, representing response returned from monitored URL

  ## Returns
  - The current state.

  ## Examples

      iex> handle_unavailable(%{in_incident_mode: true})
      %{in_incident_mode: true, ...}
  """
  def handle_unavailable(%{in_incident_mode: true, monitor: monitor} = state, _response) do
    state = %{state | start_measuring_response_time: nil}

    Pulsarius.broadcast(@monitor_topic <> monitor.id, monitor)

    schedule_check(state)
  end

  @doc """
  If there have been less than 3 consecutive successful requests while in incident mode,
  this function increments `number_of_success_retry` by 1, schedules a check after `time` milliseconds,
  and returns the updated state.

  If there have been at least 3 consecutive successful requests while in incident mode,
  this function notifies the customer that the service has recovered, sets `in_incident_mode` to `false`,
  and returns the updated state.

  ## Parameters
  - `state`: A map representing the state of the bot.

  ## Returns
  - The updated state.

  ## Examples

      iex> retry_or_notify_available(%{in_incident_mode: true, number_of_success_retry: 2})
      %{in_incident_mode: true, number_of_success_retry: 3}

      iex> retry_or_notify_available(%{in_incident_mode: true, number_of_success_retry: 3})
      %{in_incident_mode: false, number_of_success_retry: 0, incident: nil, start_measuring_response_time: nil}
  """
  defp retry_or_notify_available(%{number_of_success_retry: number_of_success_retry} = state) do
    if number_of_success_retry >= 3 do
      {:ok, incident} = Incidents.auto_resolve(state.incident)
      {:ok, monitor} = Monitoring.update_monitor(state.monitor, %{status: :active})

      new_state = %{
        state
        | monitor: monitor,
          incident: nil,
          number_of_success_retry: 0,
          in_incident_mode: false,
          start_measuring_response_time: nil
      }

      incident = Pulsarius.Repo.preload(incident, [:monitor])

      Pulsarius.broadcast(@incidents_topic, {:incident_auto_resolved, incident})
      Pulsarius.broadcast(@monitor_topic <> monitor.id, monitor)

      schedule_check(new_state)
    else
      Process.send_after(self(), :check, 3000)
      %{state | number_of_success_retry: number_of_success_retry + 1}
    end
  end

  @doc """
  If the bot receives an error response, it will either retry sending the request or notify about an incident
  depending on the number of retries that have already been attempted.

  If the number of retries is greater than or equal to the maximum allowed limit, an incident is created,
  the monitor status is set to inactive, and a notification is broadcasted. Otherwise, the function schedules
  a check after a delay of 1 second and increments the number of retries by 1.

  ## Parameters
  - `state`: A map representing the state of the bot.

  ## Returns
  - A new state with updated retry and incident information, and the in_incident_mode flag set to true.

  ## Examples

      iex> retry_or_notify_unavailable(%{retries: 2, retry_limit: 3})
      %{in_incident_mode: true, retries: 3, ...}
  """
  defp retry_or_notify_unavailable(state, response) do
    if state.retries >= state.retry_limit do
      {:ok, monitor} = Monitoring.update_monitor(state.monitor, %{status: :inactive})

      {:ok, incident} =
        Incidents.create_incident(monitor, %{
          status_code: response.status_code,
          page_response: response.body
        })

      Pulsarius.broadcast(@incidents_topic, {:incident_created, incident})
      Pulsarius.broadcast(@monitor_topic <> monitor.id, monitor)

      Task.start(fn ->
        Incidents.make_and_save_screenshot(monitor.configuration.url_to_monitor, incident)
      end)

      %{
        state
        | monitor: monitor,
          incident: incident,
          in_incident_mode: true,
          start_measuring_response_time: nil
      }
    else
      Process.send_after(self(), :check, 1000)
      %{state | retries: state.retries + 1}
    end
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
      retry_limit: 3,
      number_of_success_retry: 0,
      retries: 0,
      start_measuring_response_time: nil,
      strategy: build_strategy(monitor)
    }
  end

  defp build_initial_state(monitor) do
    %{
      monitor: monitor,
      in_incident_mode: true,
      incident: monitor.active_incident,
      number_of_success_retry: 0,
      retry_limit: 3,
      retries: 0,
      start_measuring_response_time: nil,
      strategy: build_strategy(monitor)
    }
  end

  defp convert_to_ms(frequency_check_in_seconds) do
    String.to_integer(frequency_check_in_seconds) * 1000
  end

  defp schedule_first_check(state) do
    Process.send_after(self(), :check, 500)
    state
  end

  def auto_resolve_incident(state) do
    {:ok, _incident} = Incidents.auto_resolve(state.incident)
    {:ok, _monitor} = Monitoring.update_monitor(state.monitor, %{status: :active})
  end

  defp save_status_response(state) do
    params = %{
      occured_at: DateTime.utc_now(),
      response_time_in_ms: measure_response_time(state.start_measuring_response_time)
    }

    {:ok, status_response} = Monitoring.create_status_response(state.monitor, params)

    IO.inspect("SEND status response =================>")

    :ok = Pulsarius.broadcast(@monitor_topic <> state.monitor.id, status_response)

    %{state | start_measuring_response_time: nil}
  end

  defp measure_response_time(start_time) do
    System.monotonic_time(:millisecond) - start_time
  end

  defp build_strategy(monitor) do
    %{
      alert_rule: monitor.configuration.alert_rule,
      alert_condition: monitor.configuration.alert_condition
    }
  end
end
