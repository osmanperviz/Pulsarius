defmodule PulsariusWeb.UserAuth do
  @moduledoc """
  Ensures all data related to user authentication and
  authorisation are correctly added to the assigns.
  """
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
        %{assigns: %{current_user: current_user}} = socket

        case Authorisation.authorized?(current_user, url, "GET", nil) do
          true ->
            socket =
              socket
              |> Phoenix.Component.assign(:live_url, url)

            {:cont, socket}

          false ->
            socket =
              socket
              |> Phoenix.LiveView.put_flash(:error, "Not Authorized")
              |> Phoenix.LiveView.redirect(to: "/")

            {:halt, socket}
        end
      end)
      |> Phoenix.LiveView.attach_hook(:auth_hook_event, :handle_event, fn event,
                                                                          _params,
                                                                          socket ->
        %{assigns: %{current_user: current_user, live_url: url}} = socket
        case Authorisation.authorized?(current_user, url, "GET", event) do
          true ->
            {:cont, socket}

          false ->
            socket =
              socket
              |> Phoenix.LiveView.put_flash(:error, "Not Authorized")

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