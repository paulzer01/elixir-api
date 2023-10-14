defmodule RestApi.Schema.AccountTest do
  use RestApi.Support.SchemaCase

  alias RestApi.Accounts.Account

  @expected_fields_with_types [
    id: :binary_id,
    email: :string,
    hashed_password: :string,
    inserted_at: :utc_datetime,
    updated_at: :utc_datetime
  ]

  @optional_fields [:id, :inserted_at, :updated_at]

  describe "fields and types" do
    test "fields and types" do
      actual_fields_with_types =
        for field <- Account.__schema__(:fields) do
          type = Account.__schema__(:type, field)
          {field, type}
        end

      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = valid_params(@expected_fields_with_types)

      changeset = Account.changeset(%Account{}, valid_params)
      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @expected_fields_with_types, field not in [:hashed_password] do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]

        assert actual == expected,
               "Expected #{inspect(expected)} for #{inspect(field)}, got #{inspect(actual)}."
      end

      assert Bcrypt.verify_pass(valid_params["hashed_password"], changes.hashed_password),
             "Passwords do not match."
    end

    test "error: returns an error changeset when given un-castable values" do
      invalid_params = invalid_params(@expected_fields_with_types)

      assert %Changeset{valid?: false, errors: errors} =
               Account.changeset(%Account{}, invalid_params)

      for {field, _} <- @expected_fields_with_types do
        assert errors[field], "The field #{inspect(field)} is missing from errors."

        {_, metadata} = errors[field]

        assert metadata[:validation] == :cast,
               "The validation for #{inspect(field)} should :cast. Getting #{inspect(metadata[:validation])} instead."
      end
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} =
               Account.changeset(%Account{}, params)

      for {field, _} <- @expected_fields_with_types, field not in @optional_fields do
        assert errors[field], "The field #{inspect(field)} is missing from errors."

        {_, metadata} = errors[field]

        assert metadata[:validation] == :required,
               "The validation for #{inspect(field)} should :required. Getting #{inspect(metadata[:validation])} instead."
      end

      for field <- @optional_fields do
        refute errors[field],
               "The optional field #{inspect(field)} should not be in errors as it should not be required."
      end
    end

    test "error: returns error changeset when an email address is reused" do
      Ecto.Adapters.SQL.Sandbox.checkout(RestApi.Repo)

      {:ok, existing_account} =
        %Account{}
        |> Account.changeset(valid_params(@expected_fields_with_types))
        |> RestApi.Repo.insert()

      changeset_with_repeated_email =
        %Account{}
        |> Account.changeset(valid_params(@expected_fields_with_types))
        |> Changeset.put_change(:email, existing_account.email)

      assert {:error, %Changeset{valid?: false, errors: errors}} =
               RestApi.Repo.insert(changeset_with_repeated_email)

      assert errors[:email], "The field :email is missing from errors."

      {_, metadata} = errors[:email]

      assert metadata[:constraint] == :unique,
             "The constraint for :email should :unique. Getting #{inspect(metadata[:validation])} instead."
    end
  end
end
