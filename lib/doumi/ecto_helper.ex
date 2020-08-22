if Code.ensure_loaded?(Ecto) do
  defmodule Doumi.EctoHelper do
    @term_message_map %{
      invalid: "is invalid",
      not_exist: "does not exist",
      missing_required_param: "can't be blank",
      already_exist: "has already been taken",
      over_max_length: ~r/should be at most \d+/,
      under_min_length: ~r/should be at least \d+/
    }

    def has_error?(%Ecto.Changeset{} = changeset, key, message_or_term \\ "") do
      condition =
        case message_or_term do
          term when is_atom(term) -> @term_message_map[term]
          message -> message
        end

      changeset
      |> errors_on()
      |> Map.get(key, [])
      |> Enum.any?(&check_message(&1, condition))
    end

    defp check_message(message, condition) when is_binary(condition), do: message =~ condition
    defp check_message(message, %Regex{} = condition), do: Regex.match?(condition, message)

    defp errors_on(%Ecto.Changeset{} = changeset) do
      Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
        Enum.reduce(opts, message, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
    end
  end
end
