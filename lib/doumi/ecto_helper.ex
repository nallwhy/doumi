defmodule Doumi.EctoHelper do
  @changeset_error_message_map %{
    invalid: "is invalid",
    not_exist: "does not exist",
    missing_required_param: "can't be blank",
    already_exist: "has already been taken",
    over_max_length: ~r/should be at most \d+/,
    under_min_length: ~r/should be at least \d+/
  }

  def has_error?(%Ecto.Changeset{} = changeset, key, message \\ "") do
    condition =
      case message do
        message_term when is_atom(message_term) -> @changeset_error_message_map[message_term]
        message -> message
      end

    changeset
    |> errors_on()
    |> Map.get(key, [])
    |> Enum.any?(&check_message(&1, condition))
  end

  defp check_message(message, condition) when is_binary(condition), do: message =~ condition
  defp check_message(message, %Regex{} = condition), do: Regex.match?(condition, message)

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
