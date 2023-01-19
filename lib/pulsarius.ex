defmodule Pulsarius do
  @moduledoc """
  Pulsarius keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Pulsarius.PubSub, topic)
  end

  def broadcast(topic, payload) do
    Phoenix.PubSub.broadcast(
      Pulsarius.PubSub,
      topic,
      payload
    )
  end
end
