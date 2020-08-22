defmodule Doumi.EctoCaseHelperTest do
  use Doumi.EctoCase, async: true
  alias Doumi.EctoCaseHelper
  alias Doumi.TestRepo

  @changeset %Ecto.Changeset{
    types: %{field0: :string, field1: :integer},
    action: :update,
    changes: %{field0: "value0", field1: 1},
    errors: [],
    data: %{},
    valid?: false
  }

  describe "assert_changeset_error/3" do
    test "test success with the error" do
      changeset = %Ecto.Changeset{@changeset | errors: [field0: {"is invalid", []}]}

      EctoCaseHelper.assert_changeset_error(:field0, :invalid, fn ->
        {:error, changeset}
      end)
    end

    test "test fails with the other error changeset" do
      changeset = %Ecto.Changeset{@changeset | errors: [field0: {"does not exist", []}]}

      assert_raise ExUnit.AssertionError, fn ->
        EctoCaseHelper.assert_changeset_error(:field0, :invalid, fn ->
          {:error, changeset}
        end)
      end
    end

    test "test fails with not error changeset" do
      assert_raise ExUnit.AssertionError, fn ->
        EctoCaseHelper.assert_changeset_error(:field0, :invalid, fn ->
          {:ok, nil}
        end)
      end
    end
  end

  defmodule EctoCaseTestModule do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "ecto_case_tests" do
      field(:required_field0, :integer, primary_key: true)
      field(:required_field1, :integer, primary_key: true)
      field(:not_required_field0, :integer)
    end

    def changeset(%__MODULE__{} = data, attrs) do
      data
      |> cast(attrs, [:required_field0, :required_field1])
      |> validate_required([:required_field0, :required_field1])
    end
  end

  describe "assert_wo_required_errors/3" do
    @valid_attrs %{
      required_field0: 0,
      required_field1: 1,
      not_required_field0: 2
    }

    test "test success with required fields" do
      EctoCaseHelper.assert_wo_required_errors(
        [:required_field0, :required_field1],
        fn data, attrs ->
          data
          |> EctoCaseTestModule.changeset(attrs)
          |> TestRepo.insert()
        end,
        [%EctoCaseTestModule{}, @valid_attrs]
      )
    end

    test "test fails with not required fields" do
      assert_raise ExUnit.AssertionError, fn ->
        EctoCaseHelper.assert_wo_required_errors(
          [:not_required_field0],
          fn data, attrs ->
            data
            |> EctoCaseTestModule.changeset(attrs)
            |> TestRepo.insert()
          end,
          [%EctoCaseTestModule{}, @valid_attrs]
        )
      end
    end
  end

  describe "get_by/3" do
    setup do
      Application.put_env(:doumi, :default_repo, TestRepo)

      data0 = TestRepo.insert!(%EctoCaseTestModule{required_field0: 0, required_field1: 0})
      data1 = TestRepo.insert!(%EctoCaseTestModule{required_field0: 1, required_field1: 1})

      on_exit(fn ->
        Application.put_env(:doumi, :default_repo, nil)
      end)

      %{data0: data0, data1: data1}
    end

    test "returns data with valid primary keys", %{data1: data1} do
      assert get_data =
               EctoCaseHelper.get_by(EctoCaseTestModule, %{required_field0: 1, required_field1: 1})

      assert get_data.required_field0 == data1.required_field0
      assert get_data.required_field1 == data1.required_field1
    end

    test "returns nil with invalid primary keys" do
      assert EctoCaseHelper.get_by(EctoCaseTestModule, %{required_field0: 2, required_field1: 1}) ==
               nil
    end
  end

  describe "reload/2" do
    setup do
      Application.put_env(:doumi, :default_repo, TestRepo)

      data =
        TestRepo.insert!(%EctoCaseTestModule{
          required_field0: 0,
          required_field1: 0,
          not_required_field0: 0
        })

      on_exit(fn ->
        Application.put_env(:doumi, :default_repo, nil)
      end)

      %{data: data}
    end

    test "returns data with valid data", %{data: data} do
      TestRepo.update!(Ecto.Changeset.change(data, %{not_required_field0: 1}))

      assert reloaded_data = EctoCaseHelper.reload(data)
      assert reloaded_data.not_required_field0 == 1
    end
  end
end
