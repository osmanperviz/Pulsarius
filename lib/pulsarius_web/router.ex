defmodule PulsariusWeb.Router do
  use PulsariusWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PulsariusWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/webhooks", PulsariusWeb do
    pipe_through :api
    post "/stripe", StripeWebhookController, :create
  end

  scope "/", PulsariusWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/monitor/:id/integrations/slack", IntegrationController, :index
    get "/users/invite/:token", UserInvitationController, :accept
    get "/users/join/:invitation_token", UserInvitationController, :join
  end

  # Other scopes may use custom stacks.
  # scope "/api", PulsariusWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PulsariusWeb.Telemetry

      live_session :invite, root_layout: {PulsariusWeb.LayoutView, :invite} do
        live "/invitation/:id", PulsariusWeb.InvitationLive.New, :new
        live "/invitation/join/:account_id", PulsariusWeb.InvitationLive.Join, :join
      end

      live_session :users, on_mount: [PulsariusWeb.AuthAssigns] do
        live "/monitors", PulsariusWeb.MonitorLive.Index, :index
        live "/monitors/new", PulsariusWeb.MonitorLive.New, :new
        live "/monitors/:id/edit", PulsariusWeb.MonitorLive.Edit, :edit
        live "/monitors/:id", PulsariusWeb.MonitorLive.Show, :show

        live "/monitors/:id/incidents", PulsariusWeb.IncidentsLive.Index, :index

        live "/users", PulsariusWeb.UserLive.Index, :index
        live "/users/new", PulsariusWeb.UserLive.Index, :new
        live "/users/:id/edit", PulsariusWeb.UserLive.Index, :edit
        live "/users/:id", PulsariusWeb.UserLive.Show, :show
        live "/users/:id/show/edit", PulsariusWeb.UserLive.Show, :edit

        live "/billing/pricing", PulsariusWeb.SubscriptionLive.Pricing, :pricing
        live "/billing/subscription", PulsariusWeb.SubscriptionLive.New, :new
        live "/billing/change_subscription", PulsariusWeb.SubscriptionLive.Edit, :edit
      end
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
