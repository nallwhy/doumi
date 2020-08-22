defmodule Doumi.CaseHelperTest do
  use ExUnit.Case, async: true
  alias Doumi.CaseHelper

  describe "same_records?/2" do
    defmodule RecordTestModule do
      use Ecto.Schema

      @primary_key false
      schema "record_test" do
        field(:primary_key0, :integer, primary_key: true)
        field(:primary_key1, :string, primary_key: true)
        field(:field0, :integer)
      end
    end

    test "returns true with the same records" do
      record = %RecordTestModule{
        primary_key0: 1,
        primary_key1: "a",
        field0: 1
      }

      assert CaseHelper.same_records?(record, record) == true
    end

    test "returns true with the two records have the same primary keys" do
      primary_key0 = 1
      primary_key1 = "a"

      record0 = %RecordTestModule{
        primary_key0: primary_key0,
        primary_key1: primary_key1,
        field0: 1
      }

      record1 = %RecordTestModule{
        primary_key0: primary_key0,
        primary_key1: primary_key1,
        field0: 2
      }

      assert CaseHelper.same_records?(record0, record1) == true
    end

    test "returns false with the two records have different primary keys" do
      primary_key0 = 1

      record0 = %RecordTestModule{
        primary_key0: primary_key0,
        primary_key1: "a",
        field0: 1
      }

      record1 = %RecordTestModule{
        primary_key0: primary_key0,
        primary_key1: "b",
        field0: 1
      }

      assert CaseHelper.same_records?(record0, record1) == false
    end
  end

  describe "same_fields?/3" do
    defmodule FieldTestModule do
      defstruct [:field0, :field1]
    end

    test "returns true with the two struct have the same values with the fields" do
      struct0 = %FieldTestModule{field0: 1, field1: "a"}
      struct1 = %FieldTestModule{field0: 1, field1: "b"}

      assert CaseHelper.same_fields?(struct0, struct1, [:field0]) == true
    end

    test "returns true with the two struct have not the same values with the fields" do
      struct0 = %FieldTestModule{field0: 1, field1: "a"}
      struct1 = %FieldTestModule{field0: 1, field1: "b"}

      assert CaseHelper.same_fields?(struct0, struct1, [:field1]) == false
    end
  end

  describe "same_values?/2 with DateTime" do
    test "returns true with the same datetimes" do
      now = DateTime.utc_now()

      assert CaseHelper.same_values?(now, now) == true
    end

    test "returns true with the same time but not the same precision datetimes" do
      {:ok, datetime0, _} = DateTime.from_iso8601("2015-01-23T23:50:07.123000+09:00")
      {:ok, datetime1, _} = DateTime.from_iso8601("2015-01-23T23:50:07.123+09:00")

      assert datetime0 != datetime1
      assert CaseHelper.same_values?(datetime0, datetime1) == true
    end

    test "returns false with not the same time datetimes" do
      datetime0 = DateTime.utc_now()
      datetime1 = DateTime.utc_now()

      assert CaseHelper.same_values?(datetime0, datetime1) == false
    end
  end

  describe "same_values?/2 with Decimal" do
    test "returns true with the same decimals" do
      decimal = Decimal.new("0.1")

      assert CaseHelper.same_values?(decimal, decimal) == true
    end

    test "returns true with the same value but not the same precision decimals" do
      decimal0 = Decimal.new("0.1")
      decimal1 = Decimal.new("0.10")

      assert decimal0 != decimal1
      assert CaseHelper.same_values?(decimal0, decimal1) == true
    end

    test "returns false with not the same value decimals" do
      decimal0 = Decimal.new("0.1")
      decimal1 = Decimal.new("0.2")

      assert CaseHelper.same_values?(decimal0, decimal1) == false
    end
  end
end
