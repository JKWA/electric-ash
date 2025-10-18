defmodule SuperheroDispatchWeb.Router do
  use SuperheroDispatchWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SuperheroDispatchWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SuperheroDispatchWeb do
    pipe_through :browser

    live "/", DispatchLive.Index, :index
    live "/dispatch/:id", DispatchLive.Show, :show

    live "/incidents", IncidentLive.Index, :index
    live "/incidents/new", IncidentLive.Form, :new
    live "/incidents/:id/edit", IncidentLive.Form, :edit

    live "/incidents/:id", IncidentLive.Show, :show
    live "/incidents/:id/show/edit", IncidentLive.Show, :edit

    live "/superheroes", SuperheroLive.Index, :index
    live "/superheroes/new", SuperheroLive.Form, :new
    live "/superheroes/:id", SuperheroLive.Show
    live "/superheroes/:id/edit", SuperheroLive.Form, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", SuperheroDispatchWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:superhero_dispatch, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SuperheroDispatchWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
