defmodule Doumi.LogHelper do
  defmacro __using__(_opts) do
    quote do
      require Logger
      import unquote(__MODULE__)
    end
  end

  defmacro format_log(messages) do
    quote do
      {:current_stacktrace, [_ | stacktrace]} = Process.info(self(), :current_stacktrace)

      unquote(__MODULE__).format_log(unquote(messages), __ENV__, stacktrace)
    end
  end

  def format_log(messages, env, stacktrace) do
    messages_str =
      (messages ++ [{:stacktrace, Exception.format_stacktrace(stacktrace)}])
      |> Enum.map(fn {key, message} -> "#{key}: #{inspect(message)}" end)
      |> Enum.join(", ")

    module_name = env.module |> to_string() |> String.trim_leading("Elixir.")
    {func_name, arity} = env.function
    "[#{module_name}.#{func_name}/#{arity}] " <> messages_str
  end
end
