defmodule RestApiWeb.Router do
  use RestApiWeb, :router
  use Plug.ErrorHandler

  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  def handle_errors(conn, %{reason: %{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug RestApiWeb.Auth.Pipeline
  end

  scope "/api", RestApiWeb do
    pipe_through :api
    get "/", PageController, :index
    post "/accounts/create", AccountController, :create
    post "/accounts/sign_in", AccountController, :sign_in
  end

  # Any endpoints placed within this scope will be protected by the auth pipeline and require a valid JWT
  scope "/api", RestApiWeb do
    pipe_through [:api, :auth]
    get "/accounts/by_id/:id", AccountController, :show
    # get "/accounts/:id", AccountController, :show
    # put "/accounts/:id", AccountController, :update
    # delete "/accounts/:id", AccountController, :delete
  end
end
