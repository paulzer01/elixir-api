defmodule RestApi.Schema.UserTest do
  use ExUnit.Case
  alias RestApi.Users.User

  @expected_fields_with_types [
    id: :binary_id,
    full_name: :string,
    gender: :string,
    biography: :string,
    account_id: :binary_id,
    inserted_at: :utc_datetime,
    updated_at: :utc_datetime
  ]

  @optional_fields [:full_name, :gender, :biography, :id, :inserted_at, :updated_at]

  describe "fields and types" do
    test "fields and types" do
      actual_fields_and_types =
        for field <- User.__schema__(:fields) do
          type = User.__schema__(:type, field)
          {field, type}
        end

      assert MapSet.new(actual_fields_and_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid args" do
      valid_params = %{
        "id" => Ecto.UUID.generate(),
        "full_name" => "Tester",
        "gender" => "Male",
        "biography" => "Story",
        "account_id" => Ecto.UUID.generate(),
        "inserted_at" => DateTime.utc_now(:second),
        "updated_at" => DateTime.utc_now(:second)
      }

      changeset = User.changeset(%User{}, valid_params)
      assert %Ecto.Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @expected_fields_with_types do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]

        assert actual == expected,
               "Expected #{inspect(expected)} for #{inspect(field)}, got #{inspect(actual)}."
      end
    end

    test "error: returns an error when given un-castable values" do
      invalid_params = %{
        "id" => DateTime.utc_now(:second),
        "full_name" => DateTime.utc_now(:second),
        "gender" => DateTime.utc_now(:second),
        "biography" => DateTime.utc_now(:second),
        "account_id" => DateTime.utc_now(:second),
        "inserted_at" => "DateTime.utc_now(:second)",
        "updated_at" => "DateTime.utc_now(:second)"
      }

      assert %Ecto.Changeset{valid?: false, errors: errors} =
               User.changeset(%User{}, invalid_params)

      for {field, _} <- @expected_fields_with_types do
        assert errors[field], "The field #{inspect(field)} is missing from errors."

        {_, metadata} = errors[field]

        assert metadata[:validation] == :cast,
               "The validation for #{inspect(field)} should :cast. Getting #{inspect(metadata[:validation])} instead."
      end
    end

    test "error: returns an error when required fields are missing" do
      params = %{}

      assert %Ecto.Changeset{valid?: false, errors: errors} = User.changeset(%User{}, params)

      assert errors[:account_id],
             "The field :account_id is missing from errors but is a required field."

      for field <- @optional_fields do
        refute errors[field],
               "The field #{inspect(field)} is present in errors but is an optional field."
      end
    end
  end
end
