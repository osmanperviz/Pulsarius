defmodule Pulsarius.StatusResponseSeedImporter do
  alias Pulsarius.Monitoring.StatusResponse
  alias Pulsarius.Monitoring

  def generate_seed_data(monitor, start_date, end_date) do
    generate_records(monitor, start_date, end_date, [])
  end

  defp generate_records(monitor, current_date, end_date, acc) do
    case Timex.compare(current_date, end_date) do
      -1 ->
        next_date = Timex.shift(current_date, seconds: 30)

        params = %{
          "occured_at" => current_date |> DateTime.truncate(:second),
          "response_time_in_ms" => :rand.uniform(1500)
        }

        {:ok, sr} = Monitoring.create_status_response(monitor, params)

        generate_records(monitor, next_date, end_date, [sr | acc])

      1 ->
        "Finished!"
    end
  end
end
