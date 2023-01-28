defmodule PulsariusWeb.UserLive.Show do
  use PulsariusWeb, :live_view

  alias Pulsarius.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :invitation, %{"id" => id}) do
    socket
    |> assign(:page_title, "Finish Registration")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Show User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end
end
