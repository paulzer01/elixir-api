defmodule RestApi.Support.Factory do
  use ExMachina.Ecto, repo: RestApi.Repo
  alias RestApi.Accounts.Account
  alias RestApi.Users.User

  def account_factory do
    %Account{
      email: Faker.Internet.email(),
      hashed_password: Faker.Internet.slug()
    }
  end

  def user_factory do
    %User{
      full_name: Faker.Lorem.word(),
      gender: Faker.Lorem.word(),
      biography: Faker.Lorem.sentence()
    }
  end
end
