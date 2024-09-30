defmodule PulsariusWeb.Authorisation do
 alias PulsariusWeb.Router

  def authorized?(user, path, method, event) do

    uri = URI.parse(path)
    method = String.upcase(method || "GET")
    path_info = uri.path |> String.trim_leading("/") |> String.split("/")

    # Create a mock Plug.Conn with appropriate fields
    conn = %Plug.Conn{
      host: uri.host || "localhost",
      method: method,
      path_info: path_info,
      request_path: uri.path || "/",
      query_string: uri.query || "",
      scheme: uri.scheme |> to_atom() || :http,
      port: uri.port || 80
    }

    info = Phoenix.Router.route_info(Router, method, conn.path_info, conn.host)
    route = info.route
    action = info.plug_opts


    IO.inspect(user, label: "METHOD =============>")
    IO.inspect(event, label: "EVENT =============>")
    can?(user, route, "#{event || action}")
  end

  defp can?(user, path, event) do
    IO.inspect(user, label: "USER =============>")
    IO.inspect(path, label: "PATH =============>")
    IO.inspect(event, label: "EVENT =============>")
    true
  end

  # defp can?(user, "/monitors/new", "save-monitor") do
  #   require IEx; IEx.pry
  #   true
  # end
  defp can?(user, "/admin", _action), do: false
  defp can?(_user, _route, _action), do: true


  defp to_atom(nil), do: :http
  defp to_atom(scheme), do: String.to_atom(scheme)
end