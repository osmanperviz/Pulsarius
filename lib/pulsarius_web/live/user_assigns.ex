defmodule PulsariusWeb.UserAssigns do
  @moduledoc """
  Ensures all data related to user like Account etc. correctly added to the assigns.
  """

  alias Phoenix.Component

  def on_mount(_conn, _params, _session, socket) do
    {:cont,
     socket
     |> assign_account()}
  end

  defp assign_account(socket) do
    current_user =
      socket.assigns.current_user
      |> Pulsarius.Repo.preload([:account])

    Component.assign_new(socket, :account, fn ->
      current_user.account
    end)
  end
end
