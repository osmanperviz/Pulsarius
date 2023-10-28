defmodule Pulsarius.Accounts.UserInvitation do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Pulsarius.Accounts.{Account, User}

  @type t :: %__MODULE__{
          email: String.t(),
          token: String.t(),
          status: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "user_invitations" do
    field :token, :string
    field :email, :string
    field :status, :string, default: "pending"
    field :type, Ecto.Enum, values: [:email, :link], default: :email

    belongs_to :account, Account,
      foreign_key: :account_id,
      type: :binary_id

    belongs_to :pending_user, User,
      foreign_key: :user_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(user_invitation, attrs \\ %{}) do
    user_invitation
    |> cast(attrs, [:token, :email, :type])
    |> validate_required([:token, :email])
    |> unique_constraint(:email, message: "An invitation has already been sent to this email address.")
  end

  def link_invitation_changeset(user_invitation, attrs) do
    user_invitation
    |> cast(attrs, [:token, :type])
    |> validate_required([:token, :type])
    |> unique_constraint(:email, message: "An invitation has already been sent to this email address.")
    |> validate_format(:email, ~r/@/)
  end

  @spec by_token(Ecto.Queryable.t(), String.t()) :: Ecto.Query.t()
  def by_token(queryable \\ __MODULE__, token) do
    from ui in queryable,
      where: ui.token == ^token
  end

  @spec by_type_and_status(Ecto.Queryable.t(), String.t()) :: Ecto.Query.t()
  def by_type_and_status(queryable \\ __MODULE__, type, status) do
    from ui in queryable,
      where: ui.type == ^type and ui.status == ^status
  end
end
