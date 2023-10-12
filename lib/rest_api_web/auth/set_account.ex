defmodule RestApiWeb.Auth.SetAccount do
  import Plug.Conn

  alias RestApiWeb.Auth.ErrorResponse
  alias RestApi.Accounts

  # https://hexdocs.pm/plug/Plug.html#module-types-of-plugs
  # a module plug is an extension of the function plug, where init/1 takes a set of options and initializes it, and call/2 accepts the connection returned by init/1 and additional options.

  def init(_opts) do
  end

  def call(conn, _opts) do
    if conn.assigns[:account] do
      conn
    else
      account_id = get_session(conn, :account_id)

      if account_id == nil, do: raise(ErrorResponse.Unauthorized)

      account = Accounts.get_account!(account_id)

      cond do
        account_id && account -> assign(conn, :account, account)
        true -> assign(conn, :account, nil)
      end
    end
  end
end
