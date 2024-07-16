defmodule PulsariusWeb.MsTeamsView do
  use Phoenix.View,
    root: "lib/pulsarius_web/notifications"

  def render_body(template, args) do
    render_json(template, args)
    |> Jason.encode!()
  end

  defp render_json("incident_created.json", _incident) do
    %{}
  end

  defp render_json("incident_auto_resolved.json", _incident) do
    %{}
  end

  defp render_json("incident_acknowledged.json", _incident) do
    %{}
  end

  defp render_json("incident_resolved.json", _incident) do
    %{}
  end

  defp render_json("monitor_paused.json", %{monitor: _monitor, user: _user}) do
    %{}
  end

  defp render_json("monitor_unpaused.json", %{monitor: _monitor, user: _user}) do
    %{}
  end
end
