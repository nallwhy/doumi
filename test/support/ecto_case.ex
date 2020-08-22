defmodule Doumi.EctoCase do
  use ExUnit.CaseTemplate

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Doumi.TestRepo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Doumi.TestRepo, {:shared, self()})
    end

    :ok
  end
end
