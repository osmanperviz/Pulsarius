defmodule PulsariusWeb.RegistrationLive.Success do
  use PulsariusWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end


  def render(assigns) do
    ~H"""
    <div class="col-lg-12 d-flex h-100 align-items-center justify-content-center">
      <div class="col-lg-6 ">Successs</div>
      </div>
    """
    end

end