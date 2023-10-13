defmodule RestApiWeb.AccountController do
  use RestApiWeb, :controller

  import RestApiWeb.Auth.AuthorizePlug

  alias RestApiWeb.Auth.{Guardian, ErrorResponse.Unauthorized}
  alias RestApi.{Accounts, Accounts.Account, Users.User, Users}

  # plugs the :is_authorized_account (right below) function into the :update and :delete actions
  plug :is_authorized when action in [:update, :delete]

  action_fallback RestApiWeb.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, %User{} = _user} <- Users.create_user(account, account_params) do
      authorize_account(conn, account.email, account_params["hashed_password"])
    end
  end

  def sign_in(conn, %{"email" => email, "hashed_password" => hashed_password}) do
    authorize_account(conn, email, hashed_password)
  end

  defp authorize_account(conn, email, hashed_password) do
    case Guardian.authenticate(email, hashed_password) do
      {:ok, account, token} ->
        conn
        |> put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:account_token, account: account, token: token)

      {:error, :unauthorized} ->
        raise Unauthorized, message: "Invalid credentials."
    end
  end

  def sign_out(conn, %{}) do
    account = conn.assigns[:account]
    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)

    conn
    |> Plug.Conn.clear_session()
    |> put_status(:ok)
    |> render(:account_token, account: account, token: nil)
  end

  def refresh_session(conn, %{}) do
    old_token = Guardian.Plug.current_token(conn)

    case Guardian.authenticate(old_token) do
      {:ok, account, new_token} ->
        conn
        |> put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:account_token, account: account, token: new_token)

      {:error, :unauthorized} ->
        raise Unauthorized, message: "Unauthorized."
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_full_account(id)
    render(conn, :show, account: account)
  end

  def update(conn, %{"account" => account_params}) do
    account = Accounts.get_account!(account_params["id"])

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, :show, account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end
