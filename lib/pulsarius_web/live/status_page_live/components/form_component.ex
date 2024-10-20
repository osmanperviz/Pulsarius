defmodule PulsariusWeb.StatusPageLive.FormComponent do
  use PulsariusWeb, :live_component

  alias Pulsarius.StatusPages
  alias Pulsarius.StatusPages.StatusPage
  alias ExAws.S3

  @impl true
  def update(%{status_page: status_page, monitors: monitors} = assigns, socket) do
    changeset = StatusPages.change_status_page(status_page)

    available_monitors =
      monitors
      |> Enum.reject(&(&1 in status_page.monitors))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:monitors, monitors)
     |> assign(:available_monitors, available_monitors)
     |> assign(:selected_monitors, status_page.monitors)
     |> allow_upload(:logo, accept: ~w(.png .jpg .jpeg), max_entries: 1)
     |> assign(layout: status_page.layout)
     |> assign(:logo, status_page.logo_url)}
  end

  @impl true
  def handle_event("validate", %{"status_page" => status_page_params}, socket) do
    changeset =
      socket.assigns.status_page
      |> StatusPage.changeset(status_page_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("filter-monitors", %{"status_page" => %{"monitor_filter" => query}}, socket) do
    monitors =
      Enum.filter(socket.assigns.changeset.data.monitors, &String.contains?(&1.name, query))

    {:noreply,
     socket |> assign(:available_monitors, monitors) |> assign(:changeset, socket.changeset)}
  end

  def handle_event("add_monitor", params, socket) do
    monitor = Enum.find(socket.assigns.monitors, fn monitor -> monitor.id == params["id"] end)
    selected_monitors = socket.assigns.selected_monitors ++ [monitor]

    available_monitors =
      Enum.reject(socket.assigns.available_monitors, fn m -> m.id == monitor.id end)

    {:noreply,
     assign(socket,
       available_monitors: available_monitors,
       selected_monitors: selected_monitors
     )}
  end

  def handle_event("remove-monitoring", %{"id" => id}, socket) do
    monitor = Enum.find(socket.assigns.monitors, &(&1.id == id))
    selected_monitors = Enum.reject(socket.assigns.selected_monitors, &(&1.id == id))

    available_monitors = socket.assigns.available_monitors ++ [monitor]

    socket =
      socket
      |> assign(:selected_monitors, selected_monitors)
      |> assign(:available_monitors, available_monitors)

    {:noreply, socket}
  end

  def handle_event("remove-uploaded-logo", _params, socket) do
    updated_params = %{"logo_url" => nil}

    save_status_page(socket, :edit, updated_params)
  end

  def handle_event("save", %{"status_page" => status_page_params}, socket) do
    with {:ok, logo_url} <- maybe_upload_to_s3(socket) do
      updated_params =
        Map.put(status_page_params, "logo_url", logo_url)

      save_status_page(socket, socket.assigns.action, updated_params)
    else
      {:error, reason} ->
        {:noreply, assign(socket, :changeset, %{logo_url: reason})}

      :no_upload ->
        save_status_page(socket, socket.assigns.action, status_page_params)
    end
  end

  def handle_event("change-layout", %{"layout" => layout}, socket) do
    {:noreply, assign(socket, layout: String.to_atom(layout))}
  end

  def handle_event("remove-logo", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :logo, ref)}
  end

  defp save_status_page(socket, :edit, status_page_params) do
    status_page_params = Map.put(status_page_params, "monitors", socket.assigns.selected_monitors)

    case StatusPages.update_status_page(socket.assigns.status_page, status_page_params) do
      {:ok, _status_page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Status page updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_status_page(socket, :new, status_page_params) do
    status_page_params =
      status_page_params
      |> Map.merge(%{
        "monitors" => socket.assigns.selected_monitors,
        "account_id" => socket.assigns.account_id
      })

    case StatusPages.create_status_page(status_page_params) do
      {:ok, _status_page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Status page created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp maybe_upload_to_s3(socket) do
    case socket.assigns.uploads.logo.entries do
      [] ->
        :no_upload

      _ ->
        upload_to_s3(socket)
    end
  end

  defp upload_to_s3(socket) do
    bucket = Application.get_env(:ex_aws, :bucket_name)
    upload_dir = "logo/"

    consume_uploaded_entries(socket, :logo, fn %{path: path}, entry ->
      dest = upload_dir <> entry.client_name
      file_content = File.read!(path)

      s3_response =
        S3.put_object(bucket, dest, file_content, content_type: entry.client_type)
        |> ExAws.request()

      case s3_response do
        {:ok, _response} ->
          {:ok, "https://#{bucket}.s3.amazonawss.com/#{dest}"}

        {:error, reason} ->
          {:error, reason}
      end
    end)
    |> List.first()
    |> then(&{:ok, &1})
  end
end
