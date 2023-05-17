defmodule Pulsarius.ConfigurationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.Configurations` context.
  """

  @doc """
  Generate a configuration.
  """
  def configuration_fixture(attrs \\ %{}) do
    {:ok, configuration} =
      attrs
      |> Enum.into(%{
        frequency_check_in_seconds: "60",
        url_to_monitor: "https://www.some-url.com",
        email_notification: true,
        sms_notification: true,
        alert_rule: :becomes_unavailable,
        alert_condition: "",
        ssl_expiry_date: DateTime.utc_now(),
        ssl_notify_before_in_days: "30",
        domain_expiry_date: DateTime.utc_now(),
        domain_notify_before_in_days: "30"
      })
      |> Pulsarius.Configurations.create_configuration()

    configuration
  end

  def build_configuration_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      frequency_check_in_seconds: "1",
      url_to_monitor: "https://www.some-url.com",
      email_notification: true,
      sms_notification: true,
      alert_rule: :becomes_unavailable,
      alert_condition: "",
      ssl_expiry_date: DateTime.utc_now(),
      ssl_notify_before_in_days: "30",
      domain_expiry_date: DateTime.utc_now(),
      domain_notify_before_in_days: "30"
    })
  end
end
