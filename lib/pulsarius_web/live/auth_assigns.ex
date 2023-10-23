defmodule PulsariusWeb.AuthAssigns do
  @moduledoc """
  Ensures all data related to user authentication and
  authorisation are correctly added to the assigns.
  """

  alias Phoenix.LiveView
  alias Phoenix.Component
  alias Pulsarius.Accounts

  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: "/")

      {:halt, socket}
    end
  end

  defp assign_current_user(socket, user_token) do
    Component.assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_email_token("user_token")
    end)
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"] do
        Accounts.get_user_by_email_token(user_token)
      end
    end)
  end
end
