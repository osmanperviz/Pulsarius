defmodule Pulsarius.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Accounts.Account

  @type t :: %__MODULE__{
          email: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          status: String.t(),
          status: boolean()
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :status, Ecto.Enum, values: [:pending, :registered], default: :pending
    field :show_onboard_progress_wizard, :boolean, default: true
    field :admin, :boolean, default: false

    belongs_to :account, Account,
      foreign_key: :account_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :last_name,
      :email,
      :status,
      :show_onboard_progress_wizard,
      :admin
    ])
    |> validate_required([:first_name, :last_name, :email, :status])
  end

  def email_invitation_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end

  def invitation_link_changeset(user, attrs) do
    user
    |> cast(attrs, [])
  end

  def full_name(%__MODULE__{first_name: nil, last_name: nil}) do
    ""
  end

  def full_name(%__MODULE__{first_name: first_name, last_name: last_name}) do
    "#{String.capitalize(first_name)} #{String.capitalize(last_name)}"
  end

  def status(%__MODULE__{status: status}) do
    Atom.to_string(status) |> String.capitalize()
  end
end
