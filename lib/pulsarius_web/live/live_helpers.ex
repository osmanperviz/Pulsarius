defmodule PulsariusWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.monitor_index_path(@socket, :index)}>
        <.live_component
          module={PulsariusWeb.MonitorLive.FormComponent}
          id={@monitor.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.monitor_index_path(@socket, :index)}
          monitor: @monitor
        />
      </.modal>
  """

  # def modal(assigns) do
  #   assigns = assign_new(assigns, :return_to, fn -> nil end)

  #   ~H"""
  #   <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
  #     <div
  #       id="modal-content"
  #       class="phx-modal-content fade-in-scale"
  #       phx-click-away={JS.dispatch("click", to: "#close")}
  #       phx-window-keydown={JS.dispatch("click", to: "#close")}
  #       phx-key="escape"
  #     >
  #       <%= if @return_to do %>
  #         <%= live_patch "✖",
  #           to: @return_to,
  #           id: "close",
  #           class: "phx-modal-close",
  #           phx_click: hide_modal()
  #         %>
  #       <% else %>
  #         <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>✖</a>
  #       <% end %>

  #       <%= render_slot(@inner_block) %>
  #     </div>
  #   </div>
  #   """
  # end

  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div
      id="123"
      class="modal fade show bg-dark"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#123"
      phx-page-loading
      style="display: block;"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <div class="modal-title"><%= @title %></div>
            <%= live_patch("✖", to: @return_to, class: "phx-modal-close") %>
          </div>
          <div class="modal-body">
            <%= render_slot(@inner_block) %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
