defmodule RestApi.Support.SchemaCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ecto.Changeset
      import RestApi.Support.SchemaCase
    end
  end

  def valid_params(fields_with_types) do
    valid_value_by_type = %{
      binary_id: fn -> Faker.UUID.v4() end,
      string: fn -> Faker.Lorem.word() end,
      utc_datetime: fn ->
        Faker.DateTime.backward(Enum.random(0..100)) |> DateTime.truncate(:second)
      end
    }

    for {field, type} <- fields_with_types, into: %{} do
      case field do
        :email -> {Atom.to_string(field), Faker.Internet.email()}
        _ -> {Atom.to_string(field), valid_value_by_type[type].()}
      end
    end
  end

  def invalid_params(field_with_types) do
    invalid_value_by_type = %{
      binary_id: fn -> Faker.DateTime.backward(Enum.random(0..100)) end,
      string: fn -> Faker.DateTime.backward(Enum.random(0..100)) end,
      utc_datetime: fn -> Faker.Lorem.word() end
    }

    for {field, type} <- field_with_types, into: %{} do
      {Atom.to_string(field), invalid_value_by_type[type].()}
    end
  end
end
