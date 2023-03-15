defmodule PulsariusWeb.MonitorLive.ConfigurationProgressComponent do
  use PulsariusWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="col-lg-12 mt-5">
      <div class="box-item d-flex">
        <div class="card box w-100">
          <.header />
          <div class="card-body d-flex">
            <.onboarding_wizard />
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
        <div class="d-flex justify-content-between">
          <span style="font-size: 12px" class="p-2 mt-1">1 / 4</span>
          <div
            class="progress mt-3"
            role="progressbar"
            aria-label="Example 1px high"
            aria-valuenow="25"
            aria-valuemin="0"
            aria-valuemax="100"
            style="height: 7px; width: 150px;"
          >
            <div class="progress-bar" style="width: 50%"></div>
          </div>
        </div>
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
                class="nav-link mb-3 p-3 shadow active"
                id="nav-monitor-tab"
                data-bs-toggle="tab"
                data-bs-target="#monitor-tab"
                role="tab"
                aria-controls="monitor-tab"
                aria-selected="true"
              >
                <span class="font-weight-bold small text-uppercase">
                  <.icon />&nbsp;  Create Monitoring
                </span>
              </a>

              <a
                class="nav-link mb-3 p-3 shadow"
                id="nav-invite-tab"
                role="tab"
                data-bs-toggle="tab"
                data-bs-target="#invite-tab"
                aria-controls="invite-tab"
                aria-selected="false"
              >
                <i class="bi bi-calendar2-event"></i>
                <span class="font-weight-bold small text-uppercase">
                  &nbsp; Invite colleagues
                </span>
              </a>

              <a
                class="nav-link mb-3 p-3 shadow"
                id="nav-integrations-tab"
                role="tab"
                data-bs-toggle="tab"
                data-bs-target="#integrations-tab"
                aria-controls="notification-tab"
                aria-selected="false"
              >
                <i class="bi bi-gear-wide-connected"></i>
                <span class="font-weight-bold small text-uppercase">&nbsp; Integrations</span>
              </a>

              <a
                class="nav-link mb-3 p-3 shadow"
                id="nav-notification-tab"
                role="tab"
                data-bs-toggle="tab"
                data-bs-target="#notification-tab"
                aria-controls="notification-tab"
                aria-selected="false"
              >
                <i class="bi bi-bell"></i>
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
                <i class="bi bi-card-image mr-4"></i>
                <span class="font-weight-bold small text-uppercase">&nbsp; Status Page</span>
              </a>
            </div>
          </div>

          <div class="col-md-9">
            <!-- Tabs content -->
            <div class="tab-content ">
              <div
                class="tab-pane fade shadow rounded show active p-5 "
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
                class="tab-pane fade shadow rounded  p-5"
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
                class="tab-pane fade shadow rounded p-5"
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
                class="tab-pane fade shadow rounded p-5"
                id="integrations-tab"
                role="tabpanel"
                aria-labelledby="nav-integrations-tab"
              >
                <i class="bi bi-slack mt-3"></i><i class="bi bi-microsoft-teams"></i>
                <h4>Connect Slack or Microsoft Teams</h4>
                <p class="count-down">Get alerted about new incidents directly on  Slack/MSTeams.</p>
                <a class="btn btn-secondary">Integrations</a>
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
          <a class="dropdown-item pb-1" href="#"><i class="bi bi-x-circle"></i>&nbsp; Dismiss</a>
        </li>
        <li>
          <a class="dropdown-item" href="#"><i class="bi bi-journal-text"></i>&nbsp; Give feedback</a>
        </li>
      </ul>
    </div>
    """
  end
end
