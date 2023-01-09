defmodule Pulsarius.EndpointDynamicSupervisor do
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

  def auto_start_monitoring() do
    Monitor.with_active_state()
    |> Repo.all()
    |> Enum.each(&start_monitoring/1)
  end

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
