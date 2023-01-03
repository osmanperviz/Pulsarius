defmodule PulsariusWeb.PageController do
  use PulsariusWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
