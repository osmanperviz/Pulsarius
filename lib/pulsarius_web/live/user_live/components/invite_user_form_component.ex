defmodule PulsariusWeb.UserLive.InviteUserFormComponent do
  @moduledoc """
  Component responsible for taking emails from user to invite.
  """
  use PulsariusWeb, :live_component

  alias Pulsarius.Accounts
  alias Ueberauth.Strategy.Passwordless

  @topic "invitations"

  def handle_event("save", %{"invite_user" => %{"email" => email} = invite_user_params}, socket) do
    # TODO: transforme this to take multiple use emails and send invitation
    # it's built like this just for sake of simplicity
    {:ok, token} = Passwordless.create_token(email)
    invite_user_params = Map.merge(invite_user_params, %{"token" => token})

    case Accounts.invite_user(socket.assigns.account, invite_user_params) do
      {:ok, user_invitation} ->
        :ok =
          Pulsarius.broadcast(
            @topic,
            {:user_invitation_created, user_invitation}
          )

        {:noreply,
         socket
         |> put_flash(:info, "Invite sent!")
         |> push_redirect(to: Routes.user_index_path(socket, :index))}

      {:error, error} ->
        Logger.error(error)

        {:noreply,
         socket
         |> put_flash(:info, "Something went wrong!")
         |> push_redirect(to: Routes.user_index_path(socket, :index))}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={:invite_user} id="user-invite-form" phx-submit="save" phx-target={@myself}>
        <%= label(f, :email) %>
        <%= text_input(f, :email, class: "form-control") %>
        <%= error_tag(f, :email) %>
      </.form>
    </div>
    """
  end
end
