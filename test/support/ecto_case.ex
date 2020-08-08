defmodule Doumi.EctoCase do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Doumi.TestRepo)
  end
end
