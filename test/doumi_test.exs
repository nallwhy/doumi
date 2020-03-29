defmodule DoumiTest do
  use ExUnit.Case
  doctest Doumi

  test "greets the world" do
    assert Doumi.hello() == :world
  end
end
