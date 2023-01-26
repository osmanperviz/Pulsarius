defmodule Pulsarius.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Pulsarius.Repo

  alias Pulsarius.Accounts.{User, Account, UserInvitation}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(account, attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:account, account)
    |> Repo.insert()
  end

  @doc """
  Creates a user with pending state, without first name and second name.

  ## Examples

      iex> create_pending_user(%{field: value})
      {:ok, %User{}}

      iex> create_pending_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pending_user(account, attrs \\ %{}) do
    %User{}
    |> User.invitation_changeset(attrs)
    |> Ecto.Changeset.put_assoc(:account, account)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a user invitation record.

  ## Examples

      iex> invite_user(account, params)
      {:ok, %UserInvitation{}}

      iex> invite_user(account, params)
      {:error, %Ecto.Changeset{}}

  """
  @spec invite_user(Account.t(), map()) :: {:ok, UserInvitation.t()} | {:error, any()}
  def invite_user(account, user_invitation_params) do
    with {:ok, user_invitation} <- do_invite_user(account, user_invitation_params),
         {:ok, _user} <- create_pending_user(account, user_invitation_params) do
      {:ok, user_invitation}
    end
  end

  defp do_invite_user(account, user_invitation_params) do
    %UserInvitation{}
    |> UserInvitation.changeset(user_invitation_params)
    |> Ecto.Changeset.put_assoc(:account, account)
    |> Repo.insert()
  end
end
