defmodule Pulsarius.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test@test.test",
        first_name: "test",
        last_name: "test"
      })
      |> Pulsarius.Accounts.create_user()

    user
  end

  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        "type" => "freelancer"
      })
      |> Pulsarius.Accounts.create_account()

    account
  end
end
