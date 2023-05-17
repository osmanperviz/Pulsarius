defmodule Pulsarius.UrlMonitor.UrlMonitorApi do
  @callback send_request(url :: String.t()) :: {:ok, HTTPoison.Response.t()} | {:error, any()}

  def send_request(url) do
    impl().send_request(url)
  end

  defp impl, do: Application.get_env(:pulsarius, :api)[:url_monitor_api]
end
