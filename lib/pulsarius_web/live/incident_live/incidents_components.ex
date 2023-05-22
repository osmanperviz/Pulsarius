defmodule PulsariusWeb.MonitorLive.IncidentsComponents do
  use PulsariusWeb, :component

  def header(assigns) do
    ~H"""
    <div class="mt-2">
      <.link
        href={Routes.incidents_index_path(PulsariusWeb.Endpoint, :index, @monitor.id)}
        class="btn bg-transparent abc p-0"
      >
        <span class="bi-chevron-left"></span> Incidents
      </.link>
      <div class="col-lg-12 d-flex m-0 p-0">
        <.incident_icon incident={@incident} fs="font-size-3-rem" />
        <div class="m-2">
          <h5 class="mt-2"><%= @monitor.name %></h5>
          <%= if @incident.status == :active do %>
            <p>
              <span class="text-danger">Ongoing</span>
              <span class="abc">
                · <%= Timex.format!(
                  @incident.occured_at,
                  "{WDshort}, {D} {Mshort} at {h24}:{0m}:{0s}"
                ) %>
              </span>
            </p>
          <% else %>
            <p>
              <span class="text-success">Resolved</span>
              <span class="abc">
                · <%= Timex.format!(
                  @incident.occured_at,
                  "{WDshort}, {D} {Mshort} at {h24}:{0m}:{0s}"
                ) %>
              </span>
            </p>
          <% end %>
        </div>
      </div>
    </div>
    <div class="col-lg-12 mt-3">
      <a
        href={Routes.incidents_index_path(PulsariusWeb.Endpoint, :index, @monitor.id)}
        role="button"
        class="btn bg-transparent abc mr-5"
      >
        <span class="bi bi-image"></span> Screenshot
      </a>

      <a
        href={Routes.monitor_show_path(PulsariusWeb.Endpoint, :show, @monitor.id)}
        role="button"
        class="btn bg-transparent abc mr-5"
      >
        <span class="bi bi-terminal"></span> Monitor
      </a>

      <button role="button" class="btn bg-transparent abc mr-4" phx-click="delete-incident">
        <span class="bi bi-trash"></span> Delete
      </button>
    </div>
    """
  end

  def incident_detail(assigns) do
    ~H"""
    <div class="box-item flex-grow-100">
      <div class="card box pb-2 pt-2 w-100">
        <div class="card-body">
          <.detail title="Checked URL" value={@monitor.configuration.url_to_monitor} />
          <div class="mb-3" />
          <.detail title="Response" value={@incident.page_response} />
        </div>
      </div>
    </div>
    """
  end

  def incident_icon(assigns) do
    fs = Map.get(assigns, :fs, "fs-6")

    ~H"""
    <span class={incident_icon_class(@incident, fs)}></span>
    """
  end

  defp detail(assigns) do
    ~H"""
    <p class="abc"><%= @title %></p>
    <div class="col-lg-12 rounded p-3  body-background-color pb-3">
      <%= @value %>
    </div>
    """
  end

  defp incident_icon_class(incident, fs) do
    if incident.status == :active,
      do: "bi bi-shield-fill-exclamation #{fs}  text-danger mt-1",
      else: "bi bi-shield-fill-check #{fs} text-success mt-1"
  end
end
