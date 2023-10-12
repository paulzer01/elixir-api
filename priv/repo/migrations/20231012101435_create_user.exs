defmodule RestApi.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :full_name, :string
      add :gender, :string
      add :biography, :text
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:user, [:account_id, :full_name])
  end
end
