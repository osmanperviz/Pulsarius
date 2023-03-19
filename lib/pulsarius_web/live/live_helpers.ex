defmodule PulsariusWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS
  import Phoenix.Component

  alias Timex.{Interval, Duration, Format.Duration.Formatter}

  def humanized_duration_in_seconds(from, until \\ Timex.now()) do
    Interval.new(from: from, until: until)
    |> Interval.duration(:seconds)
    |> Duration.from_seconds()
    |> Formatter.format(:humanized)
  end

  def humanized_duration_in_minutes(from, until \\ Timex.now()) do
    Interval.new(from: from, until: until)
    |> Interval.duration(:minutes)
    |> case do
      0 ->
        "less than an minute"

      result ->
        result
        |> Duration.from_minutes()
        |> Formatter.format(:humanized)
    end
  end

  def humanized_duration_in_hours(from, until \\ Timex.now()) do
    Interval.new(from: from, until: until)
    |> Interval.duration(:hours)
    |> case do
      0 ->
        "less than an hour"

      result ->
        result
        |> Duration.from_hours()
        |> Formatter.format(:humanized)
    end
  end

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
