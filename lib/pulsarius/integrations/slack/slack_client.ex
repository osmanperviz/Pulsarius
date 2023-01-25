defmodule Pulsarius.Integrations.Slack.SlackClient do
  def fetch_data(code) do
    case HTTPoison.post(endpoint(), encode_body(code), headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, status_code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp encode_body(code) do
    slack_integration = Application.get_env(:pulsarius, :slack_integration)

    URI.encode_query(%{
      "code" => code,
      "client_id" => slack_integration[:client_id],
      "client_secret" => slack_integration[:client_secret]
    })
  end

  defp endpoint() do
    Application.get_env(:pulsarius, :slack_integration)[:oauth_endpoint]
  end

  defp headers() do
    [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]
  end
end
