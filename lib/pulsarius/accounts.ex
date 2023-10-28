defmodule Pulsarius.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Pulsarius.Repo
  alias Ecto.Multi

  alias Pulsarius.Accounts.{User, Account, UserInvitation, UserToken}

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

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

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
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
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
  def fetch_invitation_by_type(_account_id, type, status \\ "pending") do
    UserInvitation.by_type_and_status(type, status)
    |> Repo.all()
  end

  defp generate_token(),
    do: :crypto.strong_rand_bytes(24) |> Base.url_encode64(padding: false)

  @doc """
  Checks if account has more than one user(initial registred Admin)

  ## Examples

      iex> has_team_member(?%Account{})
      [%User{}, %User{} ....]

      iex> has_team_member?(%Account{})
      []

  """
  @spec has_team_member?(Account.t()) :: boolean()
  def has_team_member?(account) do
    account
    |> Repo.preload(:users)
    |> Map.get(:users)
    |> Enum.count()
    |> Kernel.>(1)
  end

  @doc """
  Checks if account any integrations set (Slack, MSTeams...)

  ## Examples

      iex> has_any_integration_set?(%Account{})
      [%User{}, %User{} ....]

      iex> has_any_integration_set?(%Account{})
      []

  """

  @spec has_any_integration_set?(Account.t()) :: boolean()
  def has_any_integration_set?(account) do
    account
    |> Repo.preload(:integrations)
    |> Map.get(:integrations)
    |> Enum.any?()
  end

  @doc """
  Checks if account any integrations set (Slack, MSTeams...)

  ## Examples

      iex> has_any_integration_set?(%Account{})
      [%User{}, %User{} ....]

      iex> has_any_integration_set?(%Account{})
      []

  """

  @spec update_plan(Account.t(), map()) :: {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def update_plan(account, params) do
    Account.changeset(account, params)
    |> Repo.update()
  end

  def register_organization(%{"account" => account_params} = params) do
    Ecto.Multi.new()
    |> Multi.run(:account, fn _repo, %{} ->
      create_account(account_params)
    end)
    |> Multi.run(:user, fn _repo, %{account: account} ->
      create_user(account, params)
    end)
    |> Repo.transaction()
  end

  @doc """
  Delivers a "magic" sign in link to a user's email
  """
  def deliver_magic_link(user) do
    {email_token, token} = UserToken.build_email_token(user)
    Repo.insert!(token)

    Pulsarius.broadcast(
      "deliver_magic_link",
      {:send_magic_link, %{user: user, token: email_token}}
    )
  end

    @doc """
  Delivers a welcome & confirmation email to a user's email
  """
  def deliver_welcome_email(user) do
    {email_token, token} = UserToken.build_email_token(user)
    Repo.insert!(token)

    Pulsarius.broadcast(
      "deliver_welcome_email",
      {:send_welcome_email, %{user: user, token: email_token}}
    )
  end


  def get_user_by_email_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end
end
