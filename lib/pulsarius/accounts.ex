defmodule Pulsarius.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Pulsarius.Repo
  alias Ecto.Multi

  alias Pulsarius.Accounts.{User, Account, UserInvitation}

  @doc """
  Returns the list of all users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users() do
    Repo.all(User)
  end

  @doc """
  Returns the list of users for given account.

  ## Examples

      iex> list_users(acount_id)
      [%User{}, ...]

  """
  def list_users(account_id) do
    User |> where(account_id: ^account_id) |> Repo.all()
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
  Fetch account by stripe_id.

  ## Examples

      iex> fetch_account_by_stripe_id!(123)
      %Account{}

      iex> fetch_account_by_stripe_id!(456)
      ** (Ecto.NoResultsError)

  """
  def fetch_account_by_stripe_id!(stripe_id) do
    Repo.get_by(Account, stripe_id: stripe_id)
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
  Assign stripe id to  Account.

  ## Examples

      iex> assign_stripe_id(account, %{field: new_value})
      {:ok, %Account{}}

      iex> assign_stripe_id(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def assign_stripe_id(%Account{} = account, stripe_id) do
    account
    |> Account.changeset(%{stripe_id: stripe_id})
    |> Repo.update()
  end

  @doc """
  Creates a user invitation record and pending user in DB.

  ## Examples

      iex> invite_user(account, params)
      {:ok, %UserInvitation{}}

      iex> invite_user(account, params)
      {:error, %Ecto.Changeset{}}

  """
  @spec invite_user(Account.t(), map()) :: {:ok, UserInvitation.t()} | {:error, any()}
  def invite_user(account, user_invitation_params) do
    Multi.new()
    |> do_create_pending_user(account, user_invitation_params)
    |> do_invite_user(account, user_invitation_params)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result.create_user_invitation}

      error ->
        error
    end
  end

  @doc """
  Fetch invited user from invitation token

  ## Examples

      iex> fetch_user_from_invitation(account, params)
      %UserInvitation{}

      iex> invite_user(account, params)
      nil

  """
  @spec fetch_user_from_invitation(String.t()) :: UserInvitation.t() | nil
  def fetch_user_from_invitation(token) do
    UserInvitation.by_token(token)
    |> preload([:pending_user])
    |> Repo.one()
  end

  defp do_create_pending_user(multi, account, user_invitation_params) do
    multi
    |> Multi.run(:create_pending_user, fn _, _ ->
      create_pending_user(account, user_invitation_params)
    end)
  end

  defp do_invite_user(multi, account, params) do
    multi
    |> Multi.run(:create_user_invitation, fn _, %{create_pending_user: user} ->
      %UserInvitation{}
      |> UserInvitation.changeset(params)
      |> Ecto.Changeset.put_assoc(:account, account)
      |> Ecto.Changeset.put_assoc(:pending_user, user)
      |> Repo.insert()
    end)
  end
end
