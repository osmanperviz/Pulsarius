Mox.defmock(Pulsarius.UrlMonitor.MockUrlMonitorApi, for: Pulsarius.UrlMonitor.UrlMonitorApi)

Application.put_env(:pulsarius, :api, url_monitor_api: Pulsarius.UrlMonitor.MockUrlMonitorApi)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Pulsarius.Repo, :manual)
