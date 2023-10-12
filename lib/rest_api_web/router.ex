defmodule RestApiWeb.Router do
  use RestApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RestApiWeb do
    pipe_through :api
    get "/", PageController, :index
    post "/accounts/create", AccountController, :create
  end
end
