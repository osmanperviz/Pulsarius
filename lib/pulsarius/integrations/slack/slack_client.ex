defmodule Pulsarius.Integrations.Slack.SlackClient do
  @moduledoc """
  Handles communication with the Slack API for OAuth token fetching.
  """

  alias HTTPoison
  alias HTTPoison.Response
  alias HTTPoison.Error
  alias Jason, warn: false

  require Logger

  @slack_config Application.fetch_env!(:pulsarius, :slack_integration)

  @spec fetch_data(String.t()) :: {:ok, map()} | {:error, term()}
  def fetch_data(code) do
    HTTPoison.post(endpoint(), encode_body(code), headers())
    |> handle_response()
  end

  defp encode_body(code) do
    URI.encode_query(%{
      "code" => code,
      "client_id" => @slack_config[:client_id],
      "client_secret" => @slack_config[:client_secret]
    })
  end

  defp endpoint(), do: @slack_config[:oauth_endpoint]

  defp headers(), do: [{"Content-Type", "application/x-www-form-urlencoded"}]

  defp handle_response({:ok, %Response{status_code: 200, body: body}}) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        {:ok, decoded}

      error ->
        Logger.error("Failed to parse JSON: #{inspect(error)}")
        {:error, :invalid_json}
    end
  end

  defp handle_response({:ok, %Response{status_code: status_code}}) do
    Logger.warning("Received non-200 status code: #{status_code}")
    {:error, status_code}
  end

  defp handle_response({:error, %Error{reason: reason}}) do
    Logger.error("HTTP request failed: #{inspect(reason)}")
    {:error, reason}
  end
end
