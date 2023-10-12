defmodule RestApiWeb.UserJSON do
  alias RestApi.Users.User

  @doc """
  Renders a list of user.
  """
  def index(%{user: user}) do
    %{data: for(user <- user, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      full_name: user.full_name,
      gender: user.gender,
      biography: user.biography
    }
  end
end
