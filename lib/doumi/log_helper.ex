defmodule Doumi.LogHelper do
  defmacro __using__(_opts) do
    quote do
      require Logger
      import unquote(__MODULE__)
    end
  end

  defmacro format_log(messages) do
    quote do
      unquote(__MODULE__).format_log(unquote(messages), __ENV__)
    end
  end

  def format_log(messages, env) do
    messages_str =
      messages
      |> Enum.map(fn {key, message} -> "#{key}: #{inspect(message)}" end)
      |> Enum.join(", ")

    module_name = env.module |> to_string() |> String.trim_leading("Elixir.")
    {func_name, arity} = env.function
    "[#{module_name}.#{func_name}/#{arity}] " <> messages_str
  end
end
