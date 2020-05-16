defmodule Doumi.CaseHelper do
  import ExUnit.Assertions, only: [assert: 1, flunk: 1]
  import Doumi.CommonHelper, only: [defbang: 2]

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def assert_changeset_error(key, message \\ "", function) when is_function(function) do
    assert {:error, %Ecto.Changeset{} = changeset} = function.()

    case Doumi.EctoHelper.has_error?(changeset, key, message) do
      true ->
        nil

      _ ->
        message_str =
          case message do
            "" -> nil
            message when is_atom(message) -> ", :#{message}"
            _ -> ", \"#{message}\""
          end

        flunk(
          "changeset doesn't have :#{key}#{message_str} error.\n#{
            inspect(changeset, pretty: true)
          }"
        )
    end
  end

  def assert_wo_required_errors(fields_info, func, args) do
    fields_info
    |> Enum.each(fn field_info ->
      {field, key} =
        case field_info do
          {field, key} -> {field, key}
          field -> {field, field}
        end

      assert_wo_required_error(field, func, args, key)
    end)
  end

  def assert_wo_required_error(field, func, args, key \\ nil) do
    key = key || field
    {attrs, args} = args |> List.pop_at(-1)
    args = args ++ [attrs |> Map.put(field, nil)]

    assert_changeset_error(key, "can't be blank", fn ->
      apply(func, args)
    end)
  end

  def get_by(module, params, repo) do
    repo.get_by(module, params)
  end

  defbang(:get_by, 2)

  def reload(data, repo) do
    clauses =
      data.__struct__.__schema__(:primary_key)
      |> Enum.map(fn primary_key ->
        {primary_key, Map.get(data, primary_key)}
      end)

    repo.get_by(data.__struct__, clauses)
  end

  defbang(:reload, 1)

  def same_record?(a, b) do
    with true <- a.__struct__ == b.__struct__,
         primary_keys <- a.__struct__.__schema__(:primary_key),
         true <- same_fields?(a, b, primary_keys) do
      true
    else
      _ -> false
    end
  end

  def same_fields?(a, b, keys) when is_list(keys) do
    Enum.all?(keys, &same_values?(Map.get(a, &1), Map.get(b, &1)))
  end

  def same_values?(%DateTime{} = a, %DateTime{} = b), do: DateTime.compare(a, b) == :eq
  def same_values?(%Decimal{} = a, %Decimal{} = b), do: Decimal.equal?(a, b)
  def same_values?(%Decimal{} = a, b) when is_integer(b), do: Decimal.equal?(a, b)

  def same_values?(%Decimal{} = a, b) when is_float(b),
    do: Decimal.equal?(a, Decimal.from_float(b))

  def same_values?(%Decimal{} = a, b) when is_binary(b), do: Decimal.equal?(a, Decimal.new(b))
  def same_values?(a, %Decimal{} = b), do: same_values?(b, a)
  def same_values?(a, b), do: a == b

  def has_timestamps?(data) do
    data.inserted_at != nil and data.updated_at != nil
  end
end
