defmodule Pulsarius.Notifications.NotificationServer do
    use GenServer


  def start_link(monitor) do
    GenServer.start_link(
      __MODULE__,
      %{},
      name: :notivication_server
    )
  end

  def init(state) do
    {:ok, state}
  end
end