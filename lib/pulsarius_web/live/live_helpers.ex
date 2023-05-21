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

  def humanized_duration(from, until \\ Timex.now()) do
    interval = Interval.new(from: from, until: until)

    cond do
      Interval.duration(interval, :days) > 0 ->
        Interval.duration(interval, :days)
        |> Duration.from_days(interval)
        |> Formatter.format(:humanized)

      Interval.duration(interval, :hours) > 0 ->
        humanized_duration_in_hours(from, until)

      Interval.duration(interval, :minutes) > 0 ->
        humanized_duration_in_minutes(from, until)

      Interval.duration(interval, :seconds) > 0 ->
        humanized_duration_in_seconds(from, until)
    end
  end

  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div class="vh-100 d-flex justify-content-center align-items-center">
      <div id="123" class="modal fade show" style="display: block;">
        <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title" id="exampleModalCenterTitle"><%= @title %></h5>
            </div>
            <%= render_slot(@inner_block) %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
