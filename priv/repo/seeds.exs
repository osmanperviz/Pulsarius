# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Pulsarius.Repo.insert!(%Pulsarius.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

if Mix.env() == :dev do
  alias Pulsarius.Accounts

  params = %{
    "type" => "freelancer",
    "users" => [
      %{
        "email" => "test@test.test",
        "first_name" => "test",
        "last_name" => "test",
        "status" => "registered"
      }
    ]
  }

  Accounts.create_account(params)
end
