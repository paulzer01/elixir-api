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
    # https://hexdocs.pm/plug/Plug.Conn.html#fetch_session/2 fetches session + cookies
    plug :fetch_session
  end

  pipeline :auth do
    plug RestApiWeb.Auth.Pipeline
    plug RestApiWeb.Auth.SetAccount
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
    post "/accounts/update", AccountController, :update
    # delete "/accounts/:id", AccountController, :delete
    post "/accounts/sign_out", AccountController, :sign_out
    post "/accounts/refresh_session", AccountController, :refresh_session
    put "/users/update", UserController, :update
  end
end
