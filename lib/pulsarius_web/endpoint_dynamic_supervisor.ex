defmodule Pulsarius.EndpointDynamicSupervisor do
  @moduledoc """
  Module responsible for spinning monitoring processes
  """
  use DynamicSupervisor
  require Logger

  alias Pulsarius.Monitoring.Monitor
  alias Pulsarius.Repo

  def start_link(init_arg) do
    DynamicSupervisor.start_link(
      __MODULE__,
      init_arg,
      name: __MODULE__
    )
  end

  def init(_init_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

  @doc """
  When app goes down or when we are deploying all processes are shotdown,
  on app start we have to start all monitor processes again.
  """
  def auto_start_monitoring() do
    Monitor.with_active_state_and_active_incident()
    |> Repo.all()
    |> Enum.each(&start_monitoring/1)
  end

  @doc """
  Dynamically starting monitor process responsible for pinging predefined URL 
  """
  @spec start_monitoring(Monitor.t()) :: :ok
  def start_monitoring(monitor) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        __MODULE__,
        {Pulsarius.EndpointChecker, monitor}
      )

    Logger.info("Start monitoring endpoint on URL: #{monitor.configuration.url_to_monitor}")
  end
end
