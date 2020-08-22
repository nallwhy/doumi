defmodule Doumi.CaseHelper do
  if Code.ensure_loaded?(Ecto) do
    def same_records?(a, b) do
      with true <- a.__struct__ == b.__struct__,
           primary_keys <- a.__struct__.__schema__(:primary_key),
           true <- Doumi.CaseHelper.same_fields?(a, b, primary_keys) do
        true
      else
        _ -> false
      end
    end
  end

  def same_fields?(a, b, keys) when is_list(keys) do
    Enum.all?(keys, &same_values?(Map.get(a, &1), Map.get(b, &1)))
  end

  def same_values?(%DateTime{} = a, %DateTime{} = b), do: DateTime.compare(a, b) == :eq

  if Code.ensure_loaded?(Decimal) do
    def same_values?(%Decimal{} = a, %Decimal{} = b), do: Decimal.equal?(a, b)
    def same_values?(%Decimal{} = a, b) when is_integer(b), do: Decimal.equal?(a, b)

    def same_values?(%Decimal{} = a, b) when is_float(b),
      do: Decimal.equal?(a, Decimal.from_float(b))

    def same_values?(%Decimal{} = a, b) when is_binary(b), do: Decimal.equal?(a, Decimal.new(b))
    def same_values?(a, %Decimal{} = b), do: same_values?(b, a)
  end

  def same_values?(a, b), do: a == b
end
