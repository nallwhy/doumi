defmodule Doumi.LogHelperTest do
  use ExUnit.Case, async: true

  defmodule Test do
    use Doumi.LogHelper

    defstruct []

    def func(messages) do
      Logger.error(format_log(messages))
    end
  end

  describe "__using__/1" do
    test "" do
      capture =
        ExUnit.CaptureLog.capture_log([level: :error], fn ->
          Test.func(
            integer: 1,
            float: 1.0,
            boolean: true,
            atom: :atom,
            string: "string",
            list: [1, 2],
            tuple: {1, 2},
            map: %{a: 1},
            struct: %Test{}
          )
        end)

      assert capture =~
               "[error] [Doumi.LogHelperTest.Test.func/1] " <>
                 "integer: 1, " <>
                 "float: 1.0, " <>
                 "boolean: true, " <>
                 "atom: :atom, " <>
                 "string: \"string\", " <>
                 "list: [1, 2], " <>
                 "tuple: {1, 2}, " <> "map: %{a: 1}, " <> "struct: %Doumi.LogHelperTest.Test{}"
    end
  end
end
