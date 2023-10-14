defmodule RestApi.Support.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ecto.Changeset
      import RestApi.Support.DataCase
      alias RestApi.{Support.Factory, Repo}
    end
  end

  setup _ do
    Ecto.Adapters.SQL.Sandbox.mode(RestApi.Repo, :manual)
  end
end
