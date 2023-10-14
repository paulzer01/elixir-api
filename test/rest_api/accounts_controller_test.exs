defmodule RestApi.AccountsControllerTest do
  use RestApi.Support.DataCase
  alias RestApi.{Accounts, Accounts.Account}
  alias RestApi.{Users, Users.User}

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

  describe "get_account/1" do
    test "success: returns an account when given a valid id" do
      # Does not go through changesets so you need to ensure that the data that you're testing here will be inserted correctly into the database for your use-case
      account = Factory.insert(:account)

      assert %Account{} = returned_account = Accounts.get_account!(account.id)
      assert returned_account == account
    end

    test "error: raises an error when given an invalid id" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_account!(Ecto.UUID.autogenerate())
      end
    end
  end

  describe "get_account_by_email/1" do
    test "success: returns an account when given a valid email" do
      account = Factory.insert(:account)

      assert %Account{} = returned_account = Accounts.get_account_by_email(account.email)
      assert returned_account == account
    end

    test "error: returns nil when given an invalid email" do
      assert nil == Accounts.get_account_by_email("not_an_email")
    end
  end

  describe "get_full_account/1" do
    test "success: returns an account with preloaded user given a valid id" do
      # Can come back to figure out how to make this work and avoid a database call with changeset intermediary steps
      # account = Factory.insert(:account)
      # user = Factory.insert(:user, account: account)

      account_params = Factory.string_params_for(:account)
      user_params = Factory.string_params_for(:user)

      account_with_user_params = Map.put(account_params, "user", user_params)

      assert {:ok, %Account{} = account} = Accounts.create_account(account_params)

      assert {:ok, %User{}} = Users.create_user(account, user_params)

      assert %Account{} = returned_account = Accounts.get_full_account(account.id) |> IO.inspect()

      for {field, expected_value} <- account_params,
          field not in ["user"] do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(returned_account, schema_field)

        case field do
          "hashed_password" ->
            assert Bcrypt.verify_pass(expected_value, actual),
                   "Password: #{expected_value} did not match #{actual}"

          _ ->
            assert actual == expected_value,
                   "Values did not match for #{field}. Expected #{expected_value}, got #{actual}"
        end
      end

      for {field, expected_value} <- user_params |> Map.put("account_id", account.id) do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(returned_account.user, schema_field)

        assert actual == expected_value,
               "Values did not match for #{field}. Expected #{expected_value}, got #{actual}"
      end
    end
  end
end
