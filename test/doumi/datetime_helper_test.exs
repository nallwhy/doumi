defmodule Doumi.DateTimeHelperTest do
  use ExUnit.Case, async: true
  alias Doumi.DateTimeHelper

  test "now_s/0 returns current datetime with second precision" do
    assert %{microsecond: {_, 0}} = DateTimeHelper.now_s()
  end

  test "now_ms/0 returns current datetime with millisecond precision" do
    assert %{microsecond: {_, 3}} = DateTimeHelper.now_ms()
  end

  test "now_us/0 returns current datetime with microsecond precision" do
    assert %{microsecond: {_, 6}} = DateTimeHelper.now_us()
  end

  test "to_unix/1" do
    now = DateTime.utc_now()

    assert DateTimeHelper.to_unix(now) == DateTime.to_unix(now, :millisecond)
  end

  test "from_unix/1" do
    now_unix = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    {:ok, datetime0} = DateTimeHelper.from_unix(now_unix)
    {:ok, datetime1} = DateTime.from_unix(now_unix, :millisecond)

    assert DateTime.compare(datetime0, datetime1) == :eq
  end
end
