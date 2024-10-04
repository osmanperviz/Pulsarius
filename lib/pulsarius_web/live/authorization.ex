defmodule PulsariusWeb.Authorisation do
  alias Pulsarius.Accounts.Policy
  alias PulsariusWeb.Router

  def authorized?(account, path) do
    uri = URI.parse(path)
    path_info = uri.path |> String.trim_leading("/") |> String.split("/")

    # Create a mock Plug.Conn with appropriate fields
    conn = %Plug.Conn{
      host: uri.host || "localhost",
      method: "GET",
      path_info: path_info,
      request_path: uri.path || "/",
      query_string: uri.query || "",
      scheme: uri.scheme |> to_atom() || :http,
      port: uri.port || 80
    }

    info = Phoenix.Router.route_info(Router, "GET", conn.path_info, conn.host)
    route = info.route
    action = info.plug_opts

    can?(account, route)
  end

  defp can?(account, "/monitors/new") do
    Policy.can?(account, :create_monitor)
  end

  defp can?(account, "/users/new") do
    Policy.can?(account, :add_user)
  end

  defp can?(_account, _path) do
    true
  end

  defp to_atom(nil), do: :http
  defp to_atom(scheme), do: String.to_atom(scheme)
end
