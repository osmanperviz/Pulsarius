defmodule Pulsarius.UrlMonitor.HttpResponseHandler do
  @doc """
  Given an HTTP response and an alert rule, determines whether the response
  indicates that the URL is available or unavailable.

  ## Parameters
  - `response`: An `HTTPoison.Response` struct.
  - `strategy`: An map. 
     - `alert_rule`: An atom specifying the alert rule to apply.
     - `alert_condition`: The condition to apply in the alert rule.

  ## Returns
  - `:available` if the URL is considered available based on the response.
  - `:unavailable` if the URL is considered unavailable based on the response.
  """
  @type alert_strategy :: %{
          alert_rule: atom,
          alert_condition: any
        }

  @spec handle_response(
          %HTTPoison.Response{},
          alert_strategy
        ) :: :available | :unavailable
  def handle_response(
        %HTTPoison.Response{status_code: status_code, body: body},
        %{alert_rule: :becomes_unavailable, alert_condition: _alert_condition}
      ) do
    if status_code != 200, do: :unavailable, else: :available
  end

  def handle_response(
        %HTTPoison.Response{body: body},
        %{alert_rule: :contain_keyword, alert_condition: keyword}
      ) do
    if body == keyword, do: :unavailable, else: :available
  end

  def handle_response(%HTTPoison.Response{body: body}, %{
        alert_rule: :does_not_contain_keyword,
        alert_condition: keyword
      }) do
    if body == keyword, do: :available, else: :unavailable
  end

  def handle_response(
        %HTTPoison.Response{status_code: status_code},
        %{alert_rule: :http_status_other_than, alert_condition: status}
      ) do
    if status_code == status, do: :available, else: :unavailable
  end
end
