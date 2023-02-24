defmodule Pulsarius.Configurations.Configuration do
  @moduledoc """
  This module holding configuration data 
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Pulsarius.Monitoring.Monitor

  @type t :: %__MODULE__{
          frequency_check_in_seconds: String.t(),
          url_to_monitor: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "configuration" do
    field :frequency_check_in_seconds, :string
    field :url_to_monitor, :string
    field :email_notification, :boolean, default: false
    field :sms_notification, :boolean, default: false
    field :slack_notification, :boolean, default: false
    field :slack_notification_webhook_url, :string

    belongs_to :monitor, Monitor,
      foreign_key: :monitor_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(configuration, attrs) do
    configuration
    |> cast(attrs, [
      :url_to_monitor,
      :frequency_check_in_seconds,
      :sms_notification,
      :email_notification,
      :slack_notification,
      :slack_notification_webhook_url
    ])
    |> validate_required([:url_to_monitor, :frequency_check_in_seconds])
  end

  def frequency_check_in_seconds_values do
    [
      "1 minute": 60,
      "2 minutes": 120,
      "3 minutes": 180,
      "4 minutes": 240,
      "5 minutes": 300
    ]
  end
end
