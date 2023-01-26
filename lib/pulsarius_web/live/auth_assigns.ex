defmodule PulsariusWeb.AuthAssigns do
  @moduledoc """
  Ensures all data related to user authentication and
  authorisation are correctly added to the assigns.
  """

  alias Phoenix.LiveView
  alias Phoenix.Component
  alias Pulsarius.Accounts

  def on_mount(_name, params, session, socket) do
    {:cont,
     socket
     |> assign_current_user()
     |> assign_account()}
  end

  defp assign_current_user(socket) do
    # for development we will just fetch default user which we have in DB
    # in reality we will check if exists in session
    # since we don't have log in functionality yet we will just assign first user from DB
    Component.assign_new(socket, :current_user, fn ->
      Accounts.list_users() |> List.first()
    end)
  end

  defp assign_account(socket) do
    user = socket.assigns.current_user |> Pulsarius.Repo.preload([:account])

    Component.assign_new(socket, :account, fn ->
      user.account
    end)
  end
end
