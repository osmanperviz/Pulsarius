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
    attrs = Map.put(attrs, "status", "registered")

    %User{}
    |> User.changeset(attrs)
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
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """

  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Gets a single account by invitation token.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_by_account_invitation_token(123)
      %Account{}

      iex> get_by_account_invitation_token(456)
      ** nil

  """

  def get_by_account_invitation_token(invitation_token) do
    Account |> where(invitation_token: ^invitation_token) |> Repo.one()
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
    attrs = Map.put(attrs, "invitation_token", generate_token())

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
  Creates a user invitation record with email, user for invitation via email.

  ## Examples

      iex> invite_user(account, params)
      {:ok, %UserInvitation{}}

      iex> invite_user(account, params)
      {:error, %Ecto.Changeset{}}

  """
  @spec invite_user_via_email(Account.t(), String.t()) ::
          {:ok, UserInvitation.t()} | {:error, any()}
  def invite_user_via_email(account, email) do
    attrs = %{email: email, token: generate_token()}

    %UserInvitation{}
    |> UserInvitation.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:account, account)
    |> Pulsarius.Repo.insert()
  end

  @doc """
  Fetch invitation from token

  ## Examples

      iex> fetch_invitation_from_token(account, token)
      %UserInvitation{}

      iex> fetch_invitation_from_token(account, token)
      nil

  """
  @spec fetch_invitation_from_token(String.t()) :: UserInvitation.t() | nil
  def fetch_invitation_from_token(token) do
    UserInvitation.by_token(token)
    |> Repo.one()
  end

  @doc """
  Fetch invitation by type

  ## Examples

      iex> fetch_invitation_from_token(account, token)
      [%UserInvitation{}, %UserInvitation{} ....]

      iex> fetch_invitation_from_token(account, token)
      []

  """
  @spec fetch_invitation_from_token(String.t()) :: [UserInvitation.t()] | nil
  def fetch_invitation_by_type(account_id, type, status \\ "pending") do
    UserInvitation.by_type_and_status(type, status)
    |> Repo.all()
  end

  defp generate_token(),
    do: :crypto.strong_rand_bytes(24) |> Base.url_encode64(padding: false)

  def has_team_member?(account) do
    account = account |> Repo.preload(:users)
    Enum.count(account.users) > 1
  end
end
