defmodule Doumi.DateTimeHelper do
  def now_s() do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end

  def now_ms() do
    DateTime.utc_now() |> DateTime.truncate(:millisecond)
  end

  def now_us() do
    DateTime.utc_now() |> DateTime.truncate(:microsecond)
  end

  def to_unix(%DateTime{} = datetime, unit \\ :millisecond) do
    DateTime.to_unix(datetime, unit)
  end

  def from_unix(unix, unit \\ :millisecond) do
    DateTime.from_unix(unix, unit)
  end
end
