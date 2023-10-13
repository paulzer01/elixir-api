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
end
