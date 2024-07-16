defmodule Pulsarius.StatusResponseSeedImporter do
  alias Pulsarius.Monitoring

  def generate_seed_data(monitor_id, start_date, end_date) do
    Enum.reduce_while(
      generate_date_range(start_date, end_date, seconds: 30),
      [],
      fn date, acc ->
        params = build_params(date)
        case Monitoring.create_status_response(monitor_id, params) do
          {:ok, response} -> {:cont, [response | acc]}
          {:error, _reason} -> {:halt, acc}
        end
      end
    )
  end

  defp generate_date_range(start_date, end_date, interval) do
    Stream.iterate(start_date, &DateTime.add(&1, interval.seconds, :second))
    |> Stream.take_while(&DateTime.compare(&1, end_date) != :gt)
  end

  defp build_params(occurred_at) do
    %{
      "occurred_at" => DateTime.truncate(occurred_at, :second),
      "response_time_in_ms" => :rand.uniform(1500)
    }
  end
end
