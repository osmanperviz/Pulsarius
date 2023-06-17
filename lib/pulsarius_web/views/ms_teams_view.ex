defmodule PulsariusWeb.MsTeamsView do
  use Phoenix.View,
    root: "lib/pulsarius_web/notifications"

  def render_body(template, args) do
    render_json(template, args)
    |> Jason.encode!()
  end

  defp render_json("incident_created.json", incident) do
    %{}
  end

  defp render_json("incident_auto_resolved.json", incident) do
    %{}
  end

  defp render_json("incident_acknowledged.json", incident) do
    %{}
  end

  defp render_json("incident_resolved.json", incident) do
    %{}
  end

  defp render_json("monitor_paused.json", %{monitor: monitor, user: user}) do
    %{}
  end

  defp render_json("monitor_unpaused.json", %{monitor: monitor, user: user}) do
    %{}
  end
end
