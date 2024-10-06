defmodule PulsariusWeb.StatusPageLive.FormComponent do
  use PulsariusWeb, :live_component

  alias Pulsarius.StatusPages

  @impl true
  def update(%{status_page: status_page} = assigns, socket) do
    changeset = StatusPages.change_status_page(status_page)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"status_page" => status_page_params}, socket) do
    changeset =
      socket.assigns.status_page
      |> StatusPages.change_status_page(status_page_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"status_page" => status_page_params}, socket) do
    save_status_page(socket, socket.assigns.action, status_page_params)
  end

  defp save_status_page(socket, :edit, status_page_params) do
    case StatusPages.update_status_page(socket.assigns.status_page, status_page_params) do
      {:ok, _status_page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Status page updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_status_page(socket, :new, status_page_params) do
    case StatusPages.create_status_page(status_page_params) do
      {:ok, _status_page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Status page created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
