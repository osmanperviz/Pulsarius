defmodule Pulsarius.Accounts.UserInvitation do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Accounts.Account

  @type t :: %__MODULE__{
          email: String.t(),
          token: String.t()
        }

  schema "user_invitations" do
    field :email, :string
    field :token, :string

    belongs_to :account, Account,
      foreign_key: :account_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(user_invitation, attrs) do
    user_invitation
    |> cast(attrs, [:email, :token])
    |> validate_required([:email, :token])
  end
end
