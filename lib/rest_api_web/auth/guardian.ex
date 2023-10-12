defmodule RestApi.Auth.Guardian do
  use Guardian, otp_app: :rest_api
  alias RestApi.Accounts

  def subject_for_token(%{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :no_id_provided}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_account!(id) do
      nil -> {:error, :account_not_found}
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :no_id_provided}
  end

  def authenticate(email, password) do
    case Accounts.get_account_by_email(email) do
      nil ->
        {:error, :account_not_found}

      account ->
        case Bcrypt.verify_pass(password, account.hashed_password) do
          true -> create_token(account)
          false -> {:error, :unauthorized}
        end
    end
  end

  defp create_token(account) do
    {:ok, token, _claims} = encode_and_sign(account)
    {:ok, account, token}
  end
end
