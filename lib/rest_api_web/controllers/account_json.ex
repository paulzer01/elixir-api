defmodule RestApiWeb.AccountJSON do
  alias RestApi.Accounts.Account
  alias RestApiWeb.UserJSON

  @spec index(%{:accounts => any(), optional(any()) => any()}) :: %{data: list()}
  @doc """
  Renders a list of accounts.
  """
  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  @doc """
  Renders a single account.
  """
  def show(%{account: account}) do
    %{data: data_with_preloaded_user(account)}
  end

  def account_token(%{account: account, token: token}) do
    %{data: data(account, token)}
  end

  defp data(%Account{} = account) do
    %{
      id: account.id,
      email: account.email
    }
  end

  defp data(%Account{} = account, token) do
    %{
      id: account.id,
      email: account.email,
      token: token
    }
  end

  defp data_with_preloaded_user(%Account{} = account) do
    %{
      id: account.id,
      email: account.email,
      user: UserJSON.show(%{user: account.user})
    }
  end
end
