defmodule Pulsarius.UrlMonitor.UrlMonitorClient do
  @timeout 5000
  @behaviour Pulsarius.UrlMonitor.UrlMonitorApi

  @impl Pulsarius.UrlMonitor.UrlMonitorApi
  def send_request(url) do
    case HTTPoison.get(url, [], timeout: @timeout) do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code}} ->
        {:ok, %HTTPoison.Response{body: body, status_code: status_code}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
