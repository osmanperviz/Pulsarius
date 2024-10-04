defmodule Pulsarius.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(account, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        "email" => "test@test.test",
        "first_name" => "test",
        "last_name" => "test",
        "show_onboard_progress_wizard" => true,
        "admin" => false
      })

    {:ok, user} = Pulsarius.Accounts.create_user(account, attrs)

    user
  end

  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        "type" => "freelancer",
        "organization_name" => "test organisation"
      })
      |> Pulsarius.Accounts.create_account()

    account
  end
end
