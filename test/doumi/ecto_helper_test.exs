defmodule Doumi.EctoHelperTest do
  use Doumi.EctoCase, async: true
  use Doumi.EctoHelper

  # @error_changeset %Ecto.Changeset{
  #   action: :update,
  #   changes: %{field0: "value0", field1: 1},
  #   errors: [field0: {"is invalid", []}],
  #   data: %{},
  #   valid?: false
  # }

  defmodule TestModule do
    use Ecto.Schema
    import Ecto.{Query, Changeset}

    schema "test" do
      field(:field0, :boolean)
      field(:field1, :string)
      field(:field2, :integer)
    end
  end

  describe "has_error?/2" do
    test "returns true if changeset has the error" do
    end
  end

  describe "has_error?/3" do

  end
end
