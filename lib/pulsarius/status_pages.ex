defmodule Pulsarius.StatusPages do
  @moduledoc """
  The StatusPages context.
  """

  import Ecto.Query, warn: false
  alias Pulsarius.Repo

  alias Pulsarius.StatusPages.StatusPage

  @doc """
  Returns the list of status_pages.

  ## Examples

      iex> list_status_pages()
      [%StatusPage{}, ...]

  """
  def list_status_pages do
    Repo.all(StatusPage)
  end

  @doc """
  Gets a single status_page.

  Raises `Ecto.NoResultsError` if the Status page does not exist.

  ## Examples

      iex> get_status_page!(123)
      %StatusPage{}

      iex> get_status_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_status_page!(id), do: Repo.get!(StatusPage, id)

  @doc """
  Creates a status_page.

  ## Examples

      iex> create_status_page(%{field: value})
      {:ok, %StatusPage{}}

      iex> create_status_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_status_page(attrs \\ %{}) do
    %StatusPage{}
    |> StatusPage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a status_page.

  ## Examples

      iex> update_status_page(status_page, %{field: new_value})
      {:ok, %StatusPage{}}

      iex> update_status_page(status_page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_status_page(%StatusPage{} = status_page, attrs) do
    status_page
    |> StatusPage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a status_page.

  ## Examples

      iex> delete_status_page(status_page)
      {:ok, %StatusPage{}}

      iex> delete_status_page(status_page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_status_page(%StatusPage{} = status_page) do
    Repo.delete(status_page)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking status_page changes.

  ## Examples

      iex> change_status_page(status_page)
      %Ecto.Changeset{data: %StatusPage{}}

  """
  def change_status_page(%StatusPage{} = status_page, attrs \\ %{}) do
    StatusPage.changeset(status_page, attrs)
  end
end
