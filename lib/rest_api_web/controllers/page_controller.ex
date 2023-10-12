defmodule RestApiWeb.PageController do
  use RestApiWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> send_resp(:ok, "Hello World")
  end
end
