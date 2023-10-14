defmodule RestApi.AccountsControllerTest do
  use RestApi.Support.DataCase
  alias RestApi.{Accounts, Accounts.Account}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RestApi.Repo)
  end

  describe "create_account/1" do
    test "success: inserts an account in the db and returns an account" do
      params = Factory.string_params_for(:account)

      assert {:ok, %Account{} = returned_account} = Accounts.create_account(params)

      account_from_db = Repo.get(Account, returned_account.id)

      assert returned_account == account_from_db

      mutated = ["hashed_password"]

      for {param_field, expected} <- params, param_field not in mutated do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(account_from_db, schema_field)

        assert actual == expected,
               "Values did not match for #{param_field}. Expected #{expected}, got #{actual}"
      end

      assert Bcrypt.verify_pass(params["hashed_password"], returned_account.hashed_password),
             "Password: #{params["hashed_password"]} did not match #{returned_account.hashed_password}"

      assert account_from_db.inserted_at == account_from_db.updated_at
    end

    test "error: returns an error tuple when account can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Accounts.create_account(missing_params)
    end
  end
end
