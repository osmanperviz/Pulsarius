defmodule PulsariusWeb.UserAuth do
  @moduledoc """
  Ensures all data related to user authentication and
  authorisation are correctly added to the assigns.
  """
  alias Phoenix.LiveDashboard.Router
  alias Timex.Parse.DateTime.Parsers.ISO8601Extended
  alias Pulsarius.Accounts
  alias PulsariusWeb.Authorisation

  import Phoenix.LiveView

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
        |> put_flash(:error, "You must log in to access this page.")
        |> redirect(to: "/")

      {:halt, socket}
    end
  end

  def on_mount(:ensure_authorized, _params, _session, socket) do
    socket =
      socket
      |> Phoenix.LiveView.attach_hook(:auth_hook, :handle_params, fn _params, url, socket ->
        case Authorisation.authorized?(
               socket.assigns.account,
               url
             ) do
          true ->
            {:cont, Phoenix.Component.assign(socket, :live_url, url)}

          false ->
            socket =
              socket
              |> Phoenix.LiveView.put_flash(:error, "Not Authorized")
              |> Phoenix.LiveView.redirect(to: "/monitors")

            {:halt, socket}
        end
      end)

    {:cont, socket}
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    # if socket.assigns.current_user do
    #   {:halt, redirect(socket, to: Routes.monitor_index_path(socket, :index))}
    # else
    #   {:cont, socket}
    # end

    {:cont, socket}
  end

  # defp assign_current_user(socket, _user_token) do
  #   Component.assign_new(socket, :current_user, fn ->
  #     Accounts.get_user_by_email_token("user_token")
  #   end)
  # end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"] do
        Accounts.get_user_by_email_token(user_token)
      end
    end)
  end
end
