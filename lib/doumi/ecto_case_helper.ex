if Code.ensure_loaded?(Ecto) do
  defmodule Doumi.EctoCaseHelper do
    import ExUnit.Assertions, only: [assert: 1, flunk: 1]

    def assert_changeset_error(key, message_or_term \\ "", function) when is_function(function) do
      assert {:error, %Ecto.Changeset{} = changeset} = function.()

      case Doumi.EctoHelper.has_error?(changeset, key, message_or_term) do
        true ->
          nil

        _ ->
          message_str =
            case message_or_term do
              "" -> nil
              term when is_atom(term) -> ", :#{term}"
              message -> ", \"#{message}\""
            end

          flunk(
            "changeset doesn't have :#{key} #{message_str} error.\n#{
              inspect(changeset, pretty: true)
            }"
          )
      end
    end

    def assert_wo_required_errors(fields, func, args) do
      fields
      |> Enum.each(fn field ->
        assert_wo_required_error(field, func, args)
      end)
    end

    defp assert_wo_required_error(field, func, args) do
      {attrs, args} = args |> List.pop_at(-1)
      args = args ++ [attrs |> Map.put(field, nil)]

      assert_changeset_error(field, "can't be blank", fn ->
        apply(func, args)
      end)
    end

    def get_by(module, params, repo \\ nil) do
      repo = repo || Application.get_env(:doumi, :default_repo)

      repo.get_by(module, params)
    end

    def get_by!(module, params, repo \\ nil) do
      case get_by(module, params, repo) do
        nil -> raise ShouldNotNilError
        value -> value
      end
    end

    def reload(data, repo \\ nil) do
      repo = repo || Application.get_env(:doumi, :default_repo)

      clauses =
        data.__struct__.__schema__(:primary_key)
        |> Enum.map(fn primary_key ->
          {primary_key, Map.get(data, primary_key)}
        end)

      repo.get_by(data.__struct__, clauses)
    end

    def reload!(data, repo \\ nil) do
      case reload(data, repo) do
        nil -> raise ShouldNotNilError
        value -> value
      end
    end
  end
end
