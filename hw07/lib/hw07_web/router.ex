defmodule Hw07Web.Router do
  use Hw07Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Hw07Web.Plugs.FetchSession
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Hw07Web do
    pipe_through :browser

    get "/", PageController, :index
    resources "/events", EventController
    get "/users/:id/photo", UserController, :photo
    resources "/users", UserController
    resources "/comments", CommentController
    resources "/sessions", SessionController, only: [:create, :delete], singleton: true
  end

  # Other scopes may use custom stacks.
  # scope "/api", Hw07Web do
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
      live_dashboard "/dashboard", metrics: Hw07Web.Telemetry
    end
  end
end
