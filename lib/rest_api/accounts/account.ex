defmodule RestApi.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :email, :string
    field :hashed_password, :string
    has_one :user, RestApi.Users.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :hashed_password])
    |> validate_required([:email, :hashed_password])
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
