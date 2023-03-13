defmodule PulsariusWeb.MonitorLive.ConfigurationProgressComponent do
  use PulsariusWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="col-lg-12 mt-5">
      <div class="box-item d-flex">
        <div class="card box w-100">
          <.header />
          <div class="card-body d-flex">
            <section class="header">
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
                        id="v-pills-home-tab"
                        data-toggle="pill"
                        href="#v-pills-home"
                        role="tab"
                        aria-controls="v-pills-home"
                        aria-selected="true"
                      >
                        <span class="font-weight-bold small text-uppercase">
                          <.icon />&nbsp;  Create Monitoring
                        </span>
                      </a>

                      <a
                        class="nav-link mb-3 p-3 shadow"
                        id="v-pills-profile-tab"
                        data-toggle="pill"
                        href="#v-pills-profile"
                        role="tab"
                        aria-controls="v-pills-profile"
                        aria-selected="false"
                      >
                        <i class="bi bi-calendar2-event"></i>
                        <span class="font-weight-bold small text-uppercase">
                          &nbsp; Invite colleagues
                        </span>
                      </a>

                      <a
                        class="nav-link mb-3 p-3 shadow"
                        id="v-pills-messages-tab"
                        data-toggle="pill"
                        href="#v-pills-messages"
                        role="tab"
                        aria-controls="v-pills-messages"
                        aria-selected="false"
                      >
                        <i class="bi bi-gear-wide-connected"></i>
                        <span class="font-weight-bold small text-uppercase">&nbsp; Integrations</span>
                      </a>

                      <a
                        class="nav-link mb-3 p-3 shadow"
                        id="v-pills-settings-tab"
                        data-toggle="pill"
                        href="#v-pills-settings"
                        role="tab"
                        aria-controls="v-pills-settings"
                        aria-selected="false"
                      >
                        <i class="bi bi-bell"></i>
                        <span class="font-weight-bold small text-uppercase">
                          &nbsp; Notifications
                        </span>
                      </a>

                      <a
                        class="nav-link mb-3 p-3 shadow"
                        id="v-pills-status-page-tab"
                        data-toggle="pill"
                        href="#v-pills-settings"
                        role="tab"
                        aria-controls="v-pills-settings"
                        aria-selected="false"
                      >
                        <i class="bi bi-card-image mr-4"></i>
                        <span class="font-weight-bold small text-uppercase">&nbsp; Status Page</span>
                      </a>
                    </div>
                  </div>

                  <div class="col-md-9">
                    <!-- Tabs content -->
                    <div class="tab-content" id="v-pills-tabContent">
                      <div
                        class="tab-pane fade shadow rounded show active p-5"
                        id="v-pills-home"
                        role="tabpanel"
                        aria-labelledby="v-pills-home-tab"
                      >
                        <h4 class="font-italic mb-4">Personal information</h4>
                        <p class="font-italic text-muted mb-2">
                          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                        </p>
                      </div>

                      <div
                        class="tab-pane fade shadow rounded bg-white p-5"
                        id="v-pills-profile"
                        role="tabpanel"
                        aria-labelledby="v-pills-profile-tab"
                      >
                        <h4 class="font-italic mb-4">Bookings</h4>
                        <p class="font-italic text-muted mb-2">
                          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                        </p>
                      </div>

                      <div
                        class="tab-pane fade shadow rounded bg-white p-5"
                        id="v-pills-messages"
                        role="tabpanel"
                        aria-labelledby="v-pills-messages-tab"
                      >
                        <h4 class="font-italic mb-4">Reviews</h4>
                        <p class="font-italic text-muted mb-2">
                          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                        </p>
                      </div>

                      <div
                        class="tab-pane fade shadow rounded bg-white p-5"
                        id="v-pills-settings"
                        role="tabpanel"
                        aria-labelledby="v-pills-settings-tab"
                      >
                        <h4 class="font-italic mb-4">Confirm booking</h4>
                        <p class="font-italic text-muted mb-2">
                          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </section>
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

  defp tabs(assigns) do
    ~H"""
    <ul
      style="min-width: 200px;"
      class="nav nav-tabs nav-pills border-0 flex-row flex-md-column me-5 mb-3 mb-md-0 fs-6"
    >
      <li class="nav-item w-md-200px me-0 pt-1 pb-1 bcd">
        <a class="nav-link active" data-bs-toggle="tab" href="#kt_vtab_pane_1">
          <.icon />&nbsp;  Create Monitoring
        </a>
      </li>
      <li class="nav-item w-md-200px me-0 pt-1 bcd">
        <a class="nav-link" data-bs-toggle="tab" href="#kt_vtab_pane_2">
          <i class="bi bi-calendar2-event"></i>&nbsp; Invite colleagues
        </a>
      </li>
      <li class="nav-item w-md-200px pb-1 bcd">
        <a class="nav-link" data-bs-toggle="tab" href="#kt_vtab_pane_3">
          <i class="bi bi-plug-fill"></i>&nbsp; Integrations
        </a>
      </li>
      <li class="nav-item w-md-200px pt-1 pb-1 bcd">
        <a class="nav-link " data-bs-toggle="tab" href="#kt_vtab_pane_3">
          <i class="bi bi-bell"></i>&nbsp; Notifications
        </a>
      </li>
      <li class="nav-item w-md-200px pt-1 pb-1 bcd">
        <a class="nav-link" data-bs-toggle="tab" href="#kt_vtab_pane_3">
          <span class="bi bi-card-image mr-4"></span>&nbsp; Status Page
        </a>
      </li>
      <li class="nav-item w-md-200px pt-1 pb-1">
        <a class="nav-link " data-bs-toggle="tab" href="#kt_vtab_pane_3">
          <i class="bi bi-journal fa-fw"></i>&nbsp; One more
        </a>
      </li>
    </ul>
    """
  end

  defp content(assigns) do
    ~H"""
    <.content_item
      title="Create your first monitor"
      text="Check your website for a specific keyword and get alerted when it goes down."
    >
      <:button>
        <%= link("Create monitor",
          to: Routes.monitor_new_path(PulsariusWeb.Endpoint, :new),
          class: "btn btn-primary"
        ) %>
      </:button>
    </.content_item>
    """
  end

  defp content_item(assigns) do
    ~H"""
    <div class="tab-pane fade active" id="kt_vtab_pane_1" role="tabpanel">
      <div class="d-flex justify-content-center align-items-center flex-column">
        <div class="mb-2">
          <%!-- <%= render_slot(@icon) %> --%>
        </div>
        <h4 class="sub-title"><%= @title %></h4>
        <p class="count-down "><%= @text %></p>
        <%= render_slot(@button) %>
      </div>
    </div>
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
