defmodule PulsariusWeb.UserLive.InviteUserFormComponent do
  @moduledoc """
  Component responsible for taking emails from user to invite.
  """
  use PulsariusWeb, :live_component
  alias Pulsarius.Accounts
  alias Ueberauth.Strategy.Passwordless

  require Logger

  @topic "invitations"

  def handle_event(
        "send-invite",
        %{"invite_user" => %{"email" => email} = invite_user_params},
        socket
      ) do
    case Accounts.invite_user_via_email(socket.assigns.account, email) do
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
    <div class="col-lg-12 d-flex h-100 align-items-center justify-content-center">
      <div class="col-lg-5 ">
        <div class="card box pb-2 pt-2 w-100 text-center">
          <div class="card-header pb-0">
            <h6 class=""><%= @title %></h6>
            <%= if @message != nil do %>
              <p class="gray-color" style="font-size: 0.8rem"><%= @message %></p>
            <% end %>
          </div>

          <div class="card-body pt-4 pb-4">
            <.form
              :let={f}
              as={:invite_user}
              id="user-invite-form"
              phx-submit="send-invite"
              phx-target={@myself}
            >
              <%= text_input(f, :email,
                class: "form-control search-monitors",
                placeholder: "Your email"
              ) %>
              <%= error_tag(f, :email) %>
              <div class="col-lg-12 d-grid mt-4">
                <%= submit(@button_title,
                  phx_disable_with: "Saving...",
                  class: "btn btn-primary "
                ) %>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
