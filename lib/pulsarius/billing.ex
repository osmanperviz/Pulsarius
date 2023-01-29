defmodule Pulsarius.Billing do
  @moduledoc """
  The Billing context.
  """

  import Ecto.Query, warn: false
  alias Pulsarius.Repo

  alias Pulsarius.Billing.Plans
  alias Pulsarius.Billing.Subscriptions

  @doc """
  Returns the list of plans.

  ## Examples

      iex> list_plans()
      [%Plans{}, ...]

  """
  def list_plans do
    Repo.all(Plans)
  end

  @doc """
  Gets a single plans.

  Raises `Ecto.NoResultsError` if the Plans does not exist.

  ## Examples

      iex> get_plans!(123)
      %Plans{}

      iex> get_plans!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plans!(id), do: Repo.get!(Plans, id)

  @doc """
  Creates a plans.

  ## Examples

      iex> create_plans(%{field: value})
      {:ok, %Plans{}}

      iex> create_plans(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plans(attrs \\ %{}) do
    %Plans{}
    |> Plans.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a plans.

  ## Examples

      iex> update_plans(plans, %{field: new_value})
      {:ok, %Plans{}}

      iex> update_plans(plans, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plans(%Plans{} = plans, attrs) do
    plans
    |> Plans.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a plans.

  ## Examples

      iex> delete_plans(plans)
      {:ok, %Plans{}}

      iex> delete_plans(plans)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plans(%Plans{} = plans) do
    Repo.delete(plans)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plans changes.

  ## Examples

      iex> change_plans(plans)
      %Ecto.Changeset{data: %Plans{}}

  """
  def change_plans(%Plans{} = plans, attrs \\ %{}) do
    Plans.changeset(plans, attrs)
  end

  @doc """
  Returns the list of subscriptions.

  ## Examples

      iex> list_subscriptions()
      [%Subscriptions{}, ...]

  """
  def list_subscriptions do
    Repo.all(Subscriptions)
  end

  @doc """
  Gets a single subscriptions.

  Raises `Ecto.NoResultsError` if the Subscriptions does not exist.

  ## Examples

      iex> get_subscriptions!(123)
      %Subscriptions{}

      iex> get_subscriptions!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscriptions!(id), do: Repo.get!(Subscriptions, id)

  @doc """
  Creates a subscriptions.

  ## Examples

      iex> create_subscriptions(%{field: value})
      {:ok, %Subscriptions{}}

      iex> create_subscriptions(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscriptions(attrs \\ %{}) do
    %Subscriptions{}
    |> Subscriptions.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscriptions.

  ## Examples

      iex> update_subscriptions(subscriptions, %{field: new_value})
      {:ok, %Subscriptions{}}

      iex> update_subscriptions(subscriptions, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscriptions(%Subscriptions{} = subscriptions, attrs) do
    subscriptions
    |> Subscriptions.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscriptions.

  ## Examples

      iex> delete_subscriptions(subscriptions)
      {:ok, %Subscriptions{}}

      iex> delete_subscriptions(subscriptions)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscriptions(%Subscriptions{} = subscriptions) do
    Repo.delete(subscriptions)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscriptions changes.

  ## Examples

      iex> change_subscriptions(subscriptions)
      %Ecto.Changeset{data: %Subscriptions{}}

  """
  def change_subscriptions(%Subscriptions{} = subscriptions, attrs \\ %{}) do
    Subscriptions.changeset(subscriptions, attrs)
  end
end
