defmodule RestApiWeb.AccountJSON do
  alias RestApi.Accounts.Account

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
    %{data: data(account)}
  end

  def account_token(%{account: account, token: token}) do
    %{data: data_and_token(account, token)}
  end

  defp data(%Account{} = account) do
    %{
      id: account.id,
      email: account.email
      # hashed_password: account.hashed_password
    }
  end

  defp data_and_token(%Account{} = account, token) do
    %{
      id: account.id,
      email: account.email,
      token: token
    }
  end
end
