defmodule PulsariusWeb.MonitorLive.ConfigurationProgressComponent do
  use PulsariusWeb, :live_component
  alias Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <div class="col-lg-12 mt-5">
      <div class="box-item d-flex">
        <div class="card box w-100">
          <.header onboarding_progress={@onboarding_progress} />
          <div class="card-body d-flex">
            <.onboarding_wizard onboarding_progress={@onboarding_progress} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp header(assigns) do
    ~H"""
    <div
      style="background-color: #2f3647;"
      class="d-flex justify-content-between card-header sub-title pt-4 pb-2"
    >
      <h5>Onboarding progress</h5>
      <div class="d-flex justify-content-between col-lg-3">
        <.progress onboarding_progress={@onboarding_progress} />
        <.dropdown />
      </div>
    </div>
    """
  end

  defp onboarding_wizard(assigns) do
    ~H"""
    <section class="header w-100">
      <div class="">
        <div class="row">
          <div class="col-md-3">
            <!-- Tabs nav -->
            <div
              class="nav flex-column nav-pills nav-pills-custom"
              id="v-pills-tab"
              role="tablist"
              aria-orientation="vertical"
            >
              <a
                class={"nav-link mb-3 p-3 shadow #{active_item(:create_monitoring, @onboarding_progress)}"}
                id="nav-monitor-tab"
                data-bs-toggle="tab"
                data-bs-target="#monitor-tab"
                role="tab"
                aria-controls="monitor-tab"
                aria-selected="true"
              >
                <i class={icon_for(:create_monitoring, @onboarding_progress.create_monitoring)}></i>
                <span class="font-weight-bold small text-uppercase">
                  &nbsp;  Create Monitoring
                </span>
              </a>

              <a
                class={"nav-link mb-3 p-3 shadow #{active_item(:integrations, @onboarding_progress)}"}
                id="nav-integrations-tab"
                role="tab"
                data-bs-toggle="tab"
                data-bs-target="#integrations-tab"
                aria-controls="notification-tab"
                aria-selected="false"
              >
                <i class={icon_for(:integrations, @onboarding_progress.integrations)}></i>
                <span class="font-weight-bold small text-uppercase">&nbsp; Integrations</span>
              </a>

              <a
                class={"nav-link mb-3 p-3 shadow #{active_item(:invite_colleagues, @onboarding_progress)}"}
                id="nav-invite-tab"
                role="tab"
                data-bs-toggle="tab"
                data-bs-target="#invite-tab"
                aria-controls="invite-tab"
                aria-selected="false"
              >
                <i class={icon_for(:invite_colleagues, @onboarding_progress.invite_colleagues)}></i>
                <span class="font-weight-bold small text-uppercase">
                  &nbsp; Invite colleagues
                </span>
              </a>

              <a
                class={"nav-link mb-3 p-3 shadow #{active_item(:notifications, @onboarding_progress)}"}
                id="nav-notification-tab"
                role="tab"
                data-bs-toggle="tab"
                data-bs-target="#notification-tab"
                aria-controls="notification-tab"
                aria-selected="false"
              >
                <i class={icon_for(:notifications, @onboarding_progress.notifications)}></i>
                <span class="font-weight-bold small text-uppercase">
                  &nbsp; Notifications
                </span>
              </a>

              <a
                class="nav-link mb-3 p-3 shadow"
                id="nav-status-page-tab"
                role="tab"
                data-bs-toggle="tab"
                data-bs-target="#status-page-tab"
                aria-controls="status-page-tab"
                aria-selected="false"
              >
                <i class={icon_for(:status_page, @onboarding_progress.status_page)}></i>
                <span class="font-weight-bold small text-uppercase">&nbsp; Status Page</span>
              </a>
            </div>
          </div>

          <div class="col-md-9">
            <!-- Tabs content -->
            <div class="tab-content ">
              <div
                class={"tab-pane fade shadow rounded p-5 #{active_item(:create_monitoring, @onboarding_progress)}"}
                id="monitor-tab"
                role="tabpanel"
                aria-labelledby="nav-monitor-tab"
              >
                <.icon />
                <h4>Create your first monitor</h4>
                <p class="count-down">
                  Check your website for a specific keyword and get alerted when it goes down.
                </p>
                <%= link("Create Monitor",
                  to: Routes.monitor_new_path(PulsariusWeb.Endpoint, :new),
                  class: "btn btn-secondary"
                ) %>
              </div>

              <div
                class={"tab-pane fade shadow rounded p-5 #{active_item(:invite_colleagues, @onboarding_progress)}"}
                id="invite-tab"
                role="tabpanel"
                aria-labelledby="nav-invite-tab"
              >
                <i class="bi bi-people"></i>
                <h4>Invite your colleagues</h4>
                <p class="count-down">Invite your team to collaborate on incidents faster.</p>
                <%= link("Invite collegues",
                  to: Routes.user_index_path(PulsariusWeb.Endpoint, :new),
                  class: "btn btn-secondary"
                ) %>
              </div>

              <div
                class="tab-pane fade shadow rounded  p-5"
                id="notification-tab"
                role="tabpanel"
                aria-labelledby="nav-notification-tab"
              >
              </div>

              <div
                class={"tab-pane fade shadow rounded p-5  #{active_item(:status_page, @onboarding_progress)}"}
                id="status-page-tab"
                role="tabpanel"
                aria-labelledby="nav-status-page-tab"
              >
                <i class="bi bi-people pb-3"></i>
                <h4>Create a public status page</h4>
                <p class="count-down">
                  Communicate the status of your services with <br />
                  customers and build confidence in your product.
                </p>
                <a class="btn btn-secondary">Create status page</a>
              </div>

              <div
                class={"tab-pane fade shadow rounded p-5  #{active_item(:integrations, @onboarding_progress)}"}
                id="integrations-tab"
                role="tabpanel"
                aria-labelledby="nav-integrations-tab"
              >
                <i class="bi bi-slack mt-3"></i><i class="bi bi-microsoft-teams"></i>
                <h4>Connect Slack or Microsoft Teams</h4>
                <p class="count-down">Get alerted about new incidents directly on  Slack/MSTeams.</p>
                <a href="/integrations" class="btn btn-secondary">Integrations</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  defp icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="16"
      height="16"
      fill="currentColor"
      class="bi bi-activity"
      viewBox="0 0 16 16"
    >
      <path
        fill-rule="evenodd"
        d="M6 2a.5.5 0 0 1 .47.33L10 12.036l1.53-4.208A.5.5 0 0 1 12 7.5h3.5a.5.5 0 0 1 0 1h-3.15l-1.88 5.17a.5.5 0 0 1-.94 0L6 3.964 4.47 8.171A.5.5 0 0 1 4 8.5H.5a.5.5 0 0 1 0-1h3.15l1.88-5.17A.5.5 0 0 1 6 2Z"
      />
    </svg>
    """
  end

  defp dropdown(assigns) do
    ~H"""
    <div class="dropdown">
      <a class="abc" data-bs-toggle="dropdown" type="button" aria-expanded="false" id="123">
        <i class="bi bi-three-dots icon-dots"></i>
      </a>
      <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="123">
        <li>
          <a
            phx-remove={
              JS.hide(transition: {"ease-out duration-1000", "opacity-100", "opacity-0"}, time: 1000)
            }
            phx-mounted={
              JS.show(transition: {"ease-in duration-1000", "opacity-0", "opacity-100"}, time: 1000)
            }
            phx-click="dismiss-onboarding-progress-wizard"
            class="dropdown-item pb-1"
            href="#"
          >
            <i class="bi bi-x-circle"></i>&nbsp; Dismiss
          </a>
        </li>
        <li>
          <a class="dropdown-item" href="#"><i class="bi bi-journal-text"></i>&nbsp; Give feedback</a>
        </li>
      </ul>
    </div>
    """
  end

  defp progress(assigns) do
    ~H"""
    <div class="d-flex justify-content-between">
      <span style="font-size: 12px" class="p-2 mt-1">
        <%= calculate_success_steps(@onboarding_progress) %> / <%= 5 %>
      </span>
      <div
        class="progress mt-3"
        role="progressbar"
        aria-label="Example 1px high"
        aria-valuenow="20"
        aria-valuemin="0"
        aria-valuemax="100"
        style="height: 7px; width: 150px;"
      >
        <div class="progress-bar" style={calculate_percentage_width(@onboarding_progress)}></div>
      </div>
    </div>
    """
  end

  defp active_item(current_item, progress) do
    {key, value} = Enum.find(progress, fn {k, v} -> v == false end)
    if key == current_item, do: "active show", else: ""
  end

  defp icon_for(:create_monitoring, false), do: "<.icon />"
  defp icon_for(:invite_colleagues, false), do: "bi bi-calendar2-event"
  defp icon_for(:integrations, false), do: "bi bi-gear-wide-connected"
  defp icon_for(:notifications, false), do: "bi bi-bell"
  defp icon_for(:status_page, false), do: "bi bi-card-image"

  defp icon_for(_step, _accoplished), do: "bi bi-check-circle-fill text-success"

  defp calculate_success_steps(progress) do
    Enum.filter(progress, fn {k, v} -> v == true end)
    |> Enum.count()
  end

  def calculate_percentage_width(progress) do
    "width: #{calculate_success_steps(progress) / 5 * 100}% "
  end
end
