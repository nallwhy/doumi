if Code.ensure_loaded?(Ecto) do
  defmodule Doumi.RepoHelper do
    defmacro __using__(_opts) do
      quote do
        def wrap_transaction(fun, opts \\ []) do
          unquote(__MODULE__).wrap_transaction(fun, __MODULE__, opts)
        end
      end
    end

    def wrap_transaction(fun, repo, opts \\ []) do
      repo.transaction(
        fn ->
          case fun.() do
            {:ok, result} -> result
            {:error, error} -> repo.rollback(error)
          end
        end,
        opts
      )
    end
  end
end
