defmodule Doumi.EctoHelperTest do
  use Doumi.EctoCase, async: true
  alias Doumi.EctoHelper

  @changeset %Ecto.Changeset{
    types: %{field0: :string, field1: :integer},
    action: :update,
    changes: %{field0: "value0", field1: 1},
    errors: [],
    data: %{},
    valid?: false
  }

  describe "has_error?/3" do
    test "with key and message returns true if changeset has the error" do
      changeset = %Ecto.Changeset{@changeset | errors: [field0: {"is invalid", []}]}

      assert EctoHelper.has_error?(changeset, :field0, "is invalid") == true
      assert EctoHelper.has_error?(changeset, :field0, :invalid) == true
      assert EctoHelper.has_error?(changeset, :field0) == true
    end

    test "with key and message returns false if changeset don't have any errors" do
      changeset = @changeset

      assert EctoHelper.has_error?(changeset, :field0, "is invalid") == false
    end

    test "with key and message returns false if changeset has an error with the other key" do
      changeset = %Ecto.Changeset{@changeset | errors: [field0: {"is invalid", []}]}

      assert EctoHelper.has_error?(changeset, :field1, "is invalid") == false
    end

    test "with key and message returns false if changeset has an error with the other message" do
      changeset = %Ecto.Changeset{@changeset | errors: [field0: {"does not exist", []}]}

      assert EctoHelper.has_error?(changeset, :field0, "is invalid") == false
    end
  end
end
