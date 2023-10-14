defmodule RestApi.UsersControllerTest do
  use RestApi.Support.DataCase
  alias RestApi.{Users, Users.User}
  alias RestApi.{Accounts, Accounts.Account}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(RestApi.Repo)
  end

  describe "create_user/2" do
    test "success: inserts a user into the db and returns the user" do
      account_params = Factory.string_params_for(:account)
      user_params = Factory.string_params_for(:user)

      assert {:ok, %Account{} = returned_account} = Accounts.create_account(account_params)

      assert {:ok, %User{} = returned_user} = Users.create_user(returned_account, user_params),
             "User was not created"

      user_from_db = Repo.get(User, returned_user.id)

      assert returned_user == user_from_db, "Returned user did not match user from db"

      for {param_field, expected} <- user_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(user_from_db, schema_field)

        assert actual == expected,
               "Values did not match for #{param_field}. Expected #{expected}, got #{actual}"
      end

      assert user_from_db.inserted_at == user_from_db.updated_at
    end

    test "error: returns an error when attempt to create user without an account" do
      assert_raise FunctionClauseError, fn ->
        Users.create_user(nil, Factory.string_params_for(:user))
      end

      # alternative longer way
      user_params = Factory.string_params_for(:user)

      failed_user_create =
        try do
          Users.create_user(nil, user_params)
        rescue
          e in FunctionClauseError ->
            {:error, e}
        end

      assert {:error, %FunctionClauseError{}} = failed_user_create,
             "Expected {:error, %FunctionClauseError{}}, but got #{inspect(failed_user_create)}"
    end
  end
end
