defmodule RestApi.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @optional_fields [:id, :inserted_at, :updated_at]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :email, :string
    field :hashed_password, :string
    has_one :user, RestApi.Users.User

    timestamps(type: :utc_datetime)
  end

  # this is helpful if you always forget to add new fields to the changeset
  defp all_fields do
    __MODULE__.__schema__(:fields) -- @optional_fields
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, all_fields())
    |> validate_required(all_fields())
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_length(:hashed_password, max: 160)
    |> unique_constraint(:email)
    |> put_hash_password()
  end

  defp put_hash_password(
         %Ecto.Changeset{valid?: true, changes: %{hashed_password: hashed_password}} = changeset
       ) do
    change(changeset, hashed_password: Bcrypt.hash_pwd_salt(hashed_password))
  end

  defp put_hash_password(changeset), do: changeset
end
