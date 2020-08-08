defmodule Doumi.Ecto do
  def verify_ecto() do
    unless Code.ensure_loaded?(Ecto) do
      raise "Please add ecto to your dependencies."
    end
  end
end
