defmodule Pulsarius.Repo do
  use Ecto.Repo,
    otp_app: :pulsarius,
    adapter: Ecto.Adapters.Postgres
end
