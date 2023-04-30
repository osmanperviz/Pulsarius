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

  @alert_rules_values [
    :becomes_unavailable,
    :does_not_contain_keyword,
    :contain_keyword,
    :http_status_other_than
  ]

  @allowed_attrs [
    :url_to_monitor,
    :frequency_check_in_seconds,
    :sms_notification,
    :email_notification,
    :alert_condition,
    :alert_rule,
    :ssl_expiry_date,
    :ssl_notify_before_in_days,
    :domain_expiry_date,
    :domain_notify_before_in_days
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "configuration" do
    field :frequency_check_in_seconds, :string
    field :url_to_monitor, :string
    field :email_notification, :boolean, default: false
    field :sms_notification, :boolean, default: false

    field :alert_rule, Ecto.Enum, values: @alert_rules_values, default: :becomes_unavailable
    field :alert_condition, :string

    field :ssl_expiry_date, :naive_datetime, default: nil
    field :ssl_notify_before_in_days, :string, default: nil

    field :domain_expiry_date, :naive_datetime, default: nil
    field :domain_notify_before_in_days, :string, default: nil

    belongs_to :monitor, Monitor,
      foreign_key: :monitor_id,
      type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(configuration, attrs) do
    configuration
    |> cast(attrs, @allowed_attrs)
    |> validate_required([:url_to_monitor, :frequency_check_in_seconds])
    |> validate_url_format()
    |> validate_frequency_check_in_seconds_value()
    |> validate_ssl_expiry_date_and_notify_before(attrs)
    |> validate_domain_expiry_date_and_notify_before(attrs)
    |> validate_alert_condition_and_rule()
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

  def domain_and_ssl_notification_configuration do
    [
      "Don't check": 0,
      "Alert 1 day before": 1,
      "Alert 2 day before": 2,
      "Alert 3 day before": 3,
      "Alert 7 day before": 7,
      "Alert 14 day before": 14,
      "Alert 1 month before": 30,
      "Alert 2 month before": 60
    ]
  end

  def alert_rules_values do
    [
      "Becomes unavailable": :becomes_unavailable,
      "Doesn't not contain keyword": :does_not_contain_keyword,
      "Contain keyword": :contain_keyword,
      "Returns HTTP status other than": :http_status_other_than
    ]
  end

  def status_codes do
    [
      "100",
      "101",
      "102",
      "103",
      "201",
      "202",
      "203",
      "204",
      "205",
      "206",
      "300",
      "301",
      "302",
      "303",
      "304",
      "305",
      "306",
      "307",
      "400",
      "401",
      "402",
      "403",
      "404",
      "405",
      "406",
      "407",
      "408",
      "409",
      "410",
      "411",
      "412",
      "413",
      "414",
      "415",
      "415",
      "416",
      "417",
      "421",
      "422",
      "423",
      "424",
      "425",
      "425",
      "426",
      "427",
      "428",
      "429",
      "431",
      "451",
      "500",
      "501",
      "502",
      "503",
      "504",
      "505",
      "506",
      "507",
      "508",
      "509",
      "510",
      "511"
    ]
  end

  defp validate_url_format(changeset) do
    url = get_field(changeset, :url_to_monitor)

    if url &&
         !String.match?(
           url,
           ~r/^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/
         ) do
      add_error(changeset, :url_to_monitor, "not valid Application URL")
    else
      changeset
    end
  end

  defp validate_frequency_check_in_seconds_value(changeset) do
    value = get_field(changeset, :frequency_check_in_seconds)
    allowed_values = Keyword.values(frequency_check_in_seconds_values())

    if value && !Enum.member?(allowed_values, String.to_integer(value)) do
      add_error(changeset, :frequency_check_in_seconds, "invalid value")
    else
      changeset
    end
  end

  defp validate_ssl_expiry_date_and_notify_before(changeset, attrs) do
    expiry_date = Map.get(attrs, :ssl_expiry_date)
    notify_before = Map.get(attrs, :ssl_notify_before_in_days)

    if expiry_date && !is_nil(notify_before) do
      case Date.diff(expiry_date, Date.utc_today()) do
        {_, days} when days < 0 ->
          add_error(changeset, :ssl_expiry_date, "expiry date cannot be in the past")
          |> add_error(:ssl_notify_before_in_days, "cannot be set if expiry date is in the past")

        {_, days} when days < notify_before ->
          add_error(
            changeset,
            :ssl_notify_before_in_days,
            "cannot be greater than days to expiry"
          )

        _ ->
          changeset
      end
    else
      changeset
    end
  end

  defp validate_domain_expiry_date_and_notify_before(changeset, attrs) do
    expiry_date = Map.get(attrs, :domain_expiry_date)
    notify_before = Map.get(attrs, :domain_notify_before_in_days)

    if expiry_date && !is_nil(notify_before) do
      case Date.diff(expiry_date, Date.utc_today()) do
        {_, days} when days < 0 ->
          add_error(changeset, :domain_expiry_date, "expiry date cannot be in the past")
          |> add_error(
            :domain_notify_before_in_days,
            "cannot be set if expiry date is in the past"
          )

        {_, days} when days < notify_before ->
          add_error(
            changeset,
            :domain_notify_before_in_days,
            "cannot be greater than days to expiry"
          )

        _ ->
          changeset
      end
    else
      changeset
    end
  end

  defp validate_alert_condition(changeset) do
    alert_rule = get_field(changeset, :alert_rule)

    case alert_rule do
      :becomes_unavailable ->
        changeset

      :does_not_contain_keyword ->
        changeset
        |> validate_required(:alert_condition)

      :contain_keyword ->
        changeset
        |> validate_required(:alert_condition)

      :http_status_other_than ->
        changeset
        |> validate_required(:alert_condition)
        |> validate_inclusion(
          :alert_condition,
          status_codes()
        )
    end
  end

  defp validate_alert_condition_and_rule(changeset) do
    alert_rule = get_field(changeset, :alert_rule)

    case alert_rule do
      :becomes_unavailable ->
        Ecto.Changeset.change(changeset, alert_condition: nil)

      :does_not_contain_keyword ->
        changeset
        |> validate_required(:alert_condition)

      :contain_keyword ->
        changeset
        |> validate_required(:alert_condition)

      :http_status_other_than ->
        changeset
        |> validate_required(:alert_condition)
        |> validate_inclusion(:alert_condition, status_codes())
    end
  end
end
