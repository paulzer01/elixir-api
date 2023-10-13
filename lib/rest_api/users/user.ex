defmodule RestApi.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user" do
    field :full_name, :string
    field :gender, :string
    field :biography, :string
    belongs_to :account, RestApi.Accounts.Account

    timestamps(type: :utc_datetime)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, all_fields())
    |> validate_required([:account_id])
  end
end
