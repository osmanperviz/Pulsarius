defmodule Pulsarius.HttpClient do

    def execute(url) do
        HTTPoison.get! "https://east-st-production.herokuapp.com/health-check"
    end
end