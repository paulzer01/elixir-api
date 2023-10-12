defmodule RestApiWeb.UserControllerTest do
  use RestApiWeb.ConnCase

  import RestApi.UsersFixtures

  alias RestApi.Users.User

  @create_attrs %{
    full_name: "some full_name",
    gender: "some gender",
    biography: "some biography"
  }
  @update_attrs %{
    full_name: "some updated full_name",
    gender: "some updated gender",
    biography: "some updated biography"
  }
  @invalid_attrs %{full_name: nil, gender: nil, biography: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all user", %{conn: conn} do
      conn = get(conn, ~p"/api/user")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/user", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/user/#{id}")

      assert %{
               "id" => ^id,
               "biography" => "some biography",
               "full_name" => "some full_name",
               "gender" => "some gender"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/user", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/user/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/user/#{id}")

      assert %{
               "id" => ^id,
               "biography" => "some updated biography",
               "full_name" => "some updated full_name",
               "gender" => "some updated gender"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/user/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/user/#{user}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/user/#{user}")
      end
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
