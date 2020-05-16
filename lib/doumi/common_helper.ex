defmodule Doumi.CommonHelper do
  def env() do
    unquote(Mix.env())
  end

  defmacro defbang(func_name, arity) do
    module = __CALLER__.module

    args =
      0..(arity - 1)
      |> Enum.map(&Macro.var(:"arg#{&1}", module))

    quote do
      def unquote(:"#{func_name}!")(unquote_splicing(args)) do
        case apply(unquote(module), unquote(func_name), unquote(args)) do
          {:ok, value} -> value
          nil -> raise "Bang!"
          value -> value
        end
      end
    end
  end

  defmacro defasync(func_name, arity) do
    module = __CALLER__.module

    args =
      0..(arity - 1)
      |> Enum.map(&Macro.var(:"arg#{&1}", module))

    quote do
      def unquote(:"#{func_name}_async")(unquote_splicing(args)) do
        Task.async(fn -> apply(unquote(module), unquote(func_name), unquote(args)) end)
      end
    end
  end

  def to_fetch(result, error_reason \\ :not_exist) do
    case result do
      nil -> {:error, error_reason}
      result -> {:ok, result}
    end
  end
end
