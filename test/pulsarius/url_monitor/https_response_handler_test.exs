defmodule TestHttpResponseHandler do
  use ExUnit.Case

  describe "handle_response/2" do
    test "becomes_unavailable rule with non-200 status code" do
      response = %HTTPoison.Response{body: "OK", status_code: 500}
      strategy = %{alert_rule: :becomes_unavailable, alert_condition: nil}

      assert Pulsarius.UrlMonitor.HttpResponseHandler.handle_response(response, strategy) ==
               :unavailable
    end

    test "becomes_unavailable rule with 200 status code" do
      response = %HTTPoison.Response{body: "OK", status_code: 200}
      strategy = %{alert_rule: :becomes_unavailable, alert_condition: nil}

      assert Pulsarius.UrlMonitor.HttpResponseHandler.handle_response(response, strategy) ==
               :available
    end

    test "contain_keyword rule with matching body" do
      response = %HTTPoison.Response{body: "keyword", status_code: 200}
      strategy = %{alert_rule: :contain_keyword, alert_condition: "keyword"}

      assert Pulsarius.UrlMonitor.HttpResponseHandler.handle_response(response, strategy) ==
               :unavailable
    end

    test "contain_keyword rule with non-matching body" do
      response = %HTTPoison.Response{body: "not keyword", status_code: 200}
      strategy = %{alert_rule: :contain_keyword, alert_condition: "keyword"}

      assert Pulsarius.UrlMonitor.HttpResponseHandler.handle_response(response, strategy) ==
               :available
    end

    test "does_not_contain_keyword rule with matching body" do
      response = %HTTPoison.Response{body: "keyword", status_code: 200}
      strategy = %{alert_rule: :does_not_contain_keyword, alert_condition: "keyword"}

      assert Pulsarius.UrlMonitor.HttpResponseHandler.handle_response(response, strategy) ==
               :unavailable
    end

    test "does_not_contain_keyword rule with non-matching body" do
      response = %HTTPoison.Response{body: "not keyword", status_code: 200}
      strategy = %{alert_rule: :does_not_contain_keyword, alert_condition: "keyword"}

      assert Pulsarius.UrlMonitor.HttpResponseHandler.handle_response(response, strategy) ==
               :available
    end

    test "http_status_other_than rule with matching status code" do
      response = %HTTPoison.Response{body: "OK", status_code: 201}
      strategy = %{alert_rule: :http_status_other_than, alert_condition: 201}

      assert Pulsarius.UrlMonitor.HttpResponseHandler.handle_response(response, strategy) ==
               :available
    end

    test "http_status_other_than rule with non-matching status code" do
      response = %HTTPoison.Response{body: "OK", status_code: 201}
      strategy = %{alert_rule: :http_status_other_than, alert_condition: 500}

      assert Pulsarius.UrlMonitor.HttpResponseHandler.handle_response(response, strategy) ==
               :unavailable
    end
  end
end
