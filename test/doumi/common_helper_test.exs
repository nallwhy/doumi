defmodule Doumi.CommonHelperTest do
  use ExUnit.Case, async: true
  alias Doumi.CommonHelper
  alias Doumi.ShouldNotNilError

  describe "env/0" do
    test "returns current env" do
      assert CommonHelper.env() == :test
    end
  end

  describe "defbang/2" do
    defmodule BangTestModule do
      require CommonHelper

      def echo(input) do
        input
      end

      CommonHelper.defbang(:echo, 1)
    end

    test "returns result with not nil result" do
      assert BangTestModule.echo!("hi") == "hi"
    end

    test "raises ShouldNotNilError with nil result" do
      assert_raise ShouldNotNilError, fn ->
        BangTestModule.echo!(nil)
      end
    end
  end

  describe "defasync/2" do
    defmodule AsyncTestModule do
      require CommonHelper

      def echo_delayed(pid, input) do
        Process.sleep(1000)

        send(pid, {:echo, input})
      end

      CommonHelper.defasync(:echo_delayed, 2)
    end

    test "returns immediatly and do task async" do
      AsyncTestModule.echo_delayed_async(self(), "hi")

      refute_receive {:echo, "hi"}, 1000
      assert_receive {:echo, "hi"}, 100
    end
  end

  describe "to_fetch/2" do
    test "returns {:ok, result} with not nil result" do
      assert {:ok, 1} = 1 |> CommonHelper.to_fetch(:should_not_nil)
    end

    test "returns {:error, reason} with nil result" do
      assert {:error, :should_not_nil} = nil |> CommonHelper.to_fetch(:should_not_nil)
    end
  end
end
