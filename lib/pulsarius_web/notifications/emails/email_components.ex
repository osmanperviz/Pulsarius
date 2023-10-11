defmodule PulsariusWeb.EmailComponents do
  use PulsariusWeb, :component

  def footer(assigns) do
    ~H"""
    <div style="font-size: 14px; padding: 1px 32px; background-color: #fff; border-radius-bottom: 3px;">
      <%= render_slot(@inner_block) %>
      <p style="margin-bottom: 30px;">King regards,<br /> Pulsarius Team!</p>
      <div style="padding: 16px 0;border-top:1px solid #374151;">
        © Pulsarius GmbH <%= DateTime.utc_now().year %>
      </div>
    </div>
    """
  end

  slot(:title, required: true)
  slot(:inner_block, required: true)

  #   attr :open_in_browser_url, :string, required: true

  def email_box(assigns) do
    ~H"""
    <div style="height: 100%;">
      <div style="margin: 0 auto; max-width: 620px; height: 100%; font-family: Helvetica, Arial; font-size: 16px; line-height: 1.5; color: #374151">
        <div style="padding: 32px; border-radius-top: 3px; background-color: #fff; margin-top: 50px">
          <h2 style="margin: 40px 0 24px 0; color: #000; font-weight: 500;  bordertop: 2px solid red;">
            <%= render_slot(@title) %>
          </h2>
          <%= render_slot(@inner_block) %>
        </div>
        <PulsariusWeb.EmailComponents.footer>
          <%= render_slot(@footer) %>
        </PulsariusWeb.EmailComponents.footer>
      </div>
    </div>
    """
  end

  def unsubscribe_info(assigns) do
    ~H"""
    <div style="margin-top: 32px;">
      <span>Sie möchten keine Benachrichtigungen für diese Filiale erhalten?</span>
      <a href={notifications_url()} style="color: #374151; text-decoration: underline;">Klicken Sie hier</a>.
    </div>
    """
  end

  defp notifications_url() do
    Application.fetch_env!(:cafu, :notifications_url)
  end
end
