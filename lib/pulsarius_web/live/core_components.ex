defmodule PulsariusWeb.CoreComponents do
  use PulsariusWeb, :component

  attr :last_item, :boolean, default: false
  attr :title, :string, required: true
  attr :value, :string, required: true

  def box_item(assigns) do
    ~H"""
    <div class={box_item_css(@last_item)}>
      <div class="card box pb-2 pt-2 w-100">
        <div class="card-body">
          <h6><span class="abc"><%= @title %></span></h6>
          <h6><%= @value %></h6>
        </div>
      </div>
    </div>
    """
  end

  defp box_item_css(false), do: "box-item flex-grow-100"
  defp box_item_css(true), do: "box-item flex-grow-100"
end
