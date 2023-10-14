defmodule RestApiWeb.UserController do
  use RestApiWeb, :controller

  import RestApiWeb.Auth.AuthorizePlug

  alias RestApi.{Users, Users.User}

  plug :is_authorized when action in [:update, :delete]

  action_fallback RestApiWeb.FallbackController

  def index(conn, _params) do
    user = Users.list_user()
    render(conn, :index, user: user)
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.update_user(conn.assigns.account.user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
