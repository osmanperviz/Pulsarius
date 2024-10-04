defmodule Pulsarius.StatusPagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pulsarius.StatusPages` context.
  """

  @doc """
  Generate a status_page.
  """
  def status_page_fixture(attrs \\ %{}) do
    {:ok, status_page} =
      attrs
      |> Enum.into(%{
        name: "some name",
        description: "some description",
        url: "some url",
        is_public: true
      })
      |> Pulsarius.StatusPages.create_status_page()

    status_page
  end
end
