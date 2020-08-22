defmodule Doumi.QueryHelperTest do
  use Doumi.EctoCase, async: true
  alias Doumi.QueryHelper
  alias Doumi.TestRepo

  defmodule QueryTestParentModule do
    use Ecto.Schema
    import Ecto.Changeset

    schema "query_test_parents" do
    end
  end

  defmodule QueryTestModule do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    schema "query_tests" do
      belongs_to(:parent, Doumi.QueryHelperTest.QueryTestParentModule)

      field(:required_field0, :integer, primary_key: true)
      field(:required_field1, :integer, primary_key: true)
      field(:not_required_field0, :string)
    end

    def changeset_create(%__MODULE__{} = data, attrs) do
      data
      |> cast(attrs, [:required_field0, :required_field1, :not_required_field0])
      |> validate_required([:required_field0, :required_field1])
    end

    def changeset_update(%__MODULE__{} = data, attrs) do
      data
      |> cast(attrs, [:not_required_field0])
    end
  end

  defmodule QueryTestModule.Query do
    use QueryHelper, of: Doumi.QueryHelperTest.QueryTestModule

    defquery(:get, TestRepo)
    defquery(:get_by, TestRepo)
    defquery(:list, TestRepo)
    defquery(:create, TestRepo)
    defquery(:update, TestRepo)
    defquery(:delete, TestRepo)
    defquery(:count, TestRepo)

    defsubquery(:nrf0, :eq, :not_required_field0)

    def get_by_nrf0(params) do
      QueryTestModule
      |> subquery_nrf0(params)
      |> TestRepo.one()
    end

    defsubquery(:from_rf0, :gt, :required_field0)

    def get_by_from_rf0(params) do
      QueryTestModule
      |> subquery_from_rf0(params)
      |> TestRepo.one()
    end

    defsubquery(:from_rf1, :ge, :required_field1)

    def get_by_from_rf1(params) do
      QueryTestModule
      |> subquery_from_rf1(params)
      |> TestRepo.one()
    end

    defsubquery(:to_rf0, :le, :required_field0)

    def get_by_to_rf0(params) do
      QueryTestModule
      |> subquery_to_rf0(params)
      |> TestRepo.one()
    end

    defsubquery(:to_rf1, :lt, :required_field1)

    def get_by_to_rf1(params) do
      QueryTestModule
      |> subquery_to_rf1(params)
      |> TestRepo.one()
    end

    defsubquery(:in_nrf0, :in, :not_required_field0)

    def get_by_in_nrf0(params) do
      QueryTestModule
      |> subquery_in_nrf0(params)
      |> TestRepo.one()
    end

    defsubquery(:like_nrf0, :like, :not_required_field0)

    def get_by_like_nrf0(params) do
      QueryTestModule
      |> subquery_like_nrf0(params)
      |> TestRepo.one()
    end

    defsubquery(:ilike_nrf0, :ilike, :not_required_field0)

    def get_by_ilike_nrf0(params) do
      QueryTestModule
      |> subquery_ilike_nrf0(params)
      |> TestRepo.one()
    end

    def list_limit_size(params) do
      QueryTestModule
      |> limit_size(params)
      |> TestRepo.all()
    end

    def list_order_bys(params) do
      QueryTestModule
      |> order_bys(params)
      |> TestRepo.all()
    end

    def list_with_preloads(params) do
      QueryTestModule
      |> preloads(params)
      |> TestRepo.all()
    end

    def get_by_sql(params) do
      %{required_field0: required_field0} = params

      sql = "SELECT * FROM query_tests WHERE required_field0 = $1"

      [result] =
        Ecto.Adapters.SQL.query!(TestRepo, sql, [required_field0])
        |> query_results(QueryTestModule)

      result
    end
  end

  setup do
    # Application.put_env(:doumi, :default_repo, TestRepo)

    parent = TestRepo.insert!(%QueryTestParentModule{})

    data0 =
      TestRepo.insert!(%QueryTestModule{
        required_field0: 0,
        required_field1: 1,
        not_required_field0: "abc",
        parent_id: parent.id
      })

    data1 =
      TestRepo.insert!(%QueryTestModule{
        required_field0: 3,
        required_field1: 4,
        not_required_field0: "def",
        parent_id: parent.id
      })

    # on_exit(fn ->
    #   Application.put_env(:doumi, :default_repo, nil)
    # end)

    %{data0: data0, data1: data1, parent: parent}
  end

  test "defquery(:get)", %{data1: data1} do
    assert get_data1 = QueryTestModule.Query.get(3, 4)
    assert get_data1.required_field0 == data1.required_field0
    assert get_data1.required_field1 == data1.required_field1
  end

  test "defquery(:get_by)", %{data1: data1} do
    assert get_data1 = QueryTestModule.Query.get_by(not_required_field0: "def")
    assert get_data1.required_field0 == data1.required_field0
    assert get_data1.required_field1 == data1.required_field1
  end

  test "defquery(:list)", %{data0: data0, data1: data1} do
    assert [get_data0, get_data1] = QueryTestModule.Query.list()
    assert get_data0.required_field0 == data0.required_field0
    assert get_data0.required_field1 == data0.required_field1
    assert get_data1.required_field0 == data1.required_field0
    assert get_data1.required_field1 == data1.required_field1
  end

  test "defquery(:create)" do
    attrs = %{required_field0: 6, required_field1: 7, not_required_field0: "ghi"}
    assert {:ok, created_data} = QueryTestModule.Query.create(attrs)
    assert created_data.required_field0 == attrs.required_field0
    assert created_data.required_field1 == attrs.required_field1
    assert created_data.not_required_field0 == attrs.not_required_field0
  end

  test "defquery(:update)", %{data0: data0} do
    assert {:ok, updated_data} =
             QueryTestModule.Query.update(data0, %{not_required_field0: "ghi"})

    assert updated_data.required_field0 == data0.required_field0
    assert updated_data.required_field1 == data0.required_field1
    assert updated_data.not_required_field0 == "ghi"
  end

  test "defquery(:delete)", %{data0: data0} do
    assert {:ok, deleted_data} = QueryTestModule.Query.delete(data0)
    assert deleted_data.required_field0 == data0.required_field0
    assert deleted_data.required_field1 == data0.required_field1
  end

  test "defquery(:count)" do
    assert QueryTestModule.Query.count() == 2
  end

  test "defsubquery(param_name, :eq)", %{data1: data1} do
    assert get_data = QueryTestModule.Query.get_by_nrf0(%{nrf0: "def"})
    assert get_data.required_field0 == data1.required_field0
    assert get_data.required_field1 == data1.required_field1
  end

  test "defsubquery(param_name, :gt)", %{data1: data1} do
    assert get_data = QueryTestModule.Query.get_by_from_rf0(%{from_rf0: 0})
    assert get_data.required_field0 == data1.required_field0
    assert get_data.required_field1 == data1.required_field1
  end

  test "defsubquery(param_name, :ge)", %{data1: data1} do
    assert get_data = QueryTestModule.Query.get_by_from_rf1(%{from_rf1: 3})
    assert get_data.required_field0 == data1.required_field0
    assert get_data.required_field1 == data1.required_field1
  end

  test "defsubquery(param_name, :le)", %{data0: data0} do
    assert get_data = QueryTestModule.Query.get_by_to_rf0(%{to_rf0: 0})
    assert get_data.required_field0 == data0.required_field0
    assert get_data.required_field1 == data0.required_field1
  end

  test "defsubquery(param_name, :lt)", %{data0: data0} do
    assert get_data = QueryTestModule.Query.get_by_to_rf1(%{to_rf1: 3})
    assert get_data.required_field0 == data0.required_field0
    assert get_data.required_field1 == data0.required_field1
  end

  test "defsubquery(param_name, :in)", %{data1: data1} do
    assert get_data = QueryTestModule.Query.get_by_in_nrf0(%{in_nrf0: ["def", "ghi"]})
    assert get_data.required_field0 == data1.required_field0
    assert get_data.required_field1 == data1.required_field1
  end

  test "defsubquery(param_name, :like)", %{data1: data1} do
    assert get_data = QueryTestModule.Query.get_by_like_nrf0(%{like_nrf0: "ef"})
    assert get_data.required_field0 == data1.required_field0
    assert get_data.required_field1 == data1.required_field1

    assert QueryTestModule.Query.get_by_like_nrf0(%{like_nrf0: "EF"}) == nil
  end

  test "defsubquery(param_name, :ilike)", %{data1: data1} do
    assert get_data = QueryTestModule.Query.get_by_ilike_nrf0(%{ilike_nrf0: "ef"})
    assert get_data.required_field0 == data1.required_field0
    assert get_data.required_field1 == data1.required_field1

    assert get_data = QueryTestModule.Query.get_by_ilike_nrf0(%{ilike_nrf0: "EF"})
    assert get_data.required_field0 == data1.required_field0
    assert get_data.required_field1 == data1.required_field1
  end

  test "limit_size/3", %{data0: data0} do
    assert [get_data] = QueryTestModule.Query.list_limit_size(%{size: 1})
    assert get_data.required_field0 == data0.required_field0
    assert get_data.required_field1 == data0.required_field1
  end

  test "order_bys/3", %{data1: data1} do
    assert [get_data, _] =
             QueryTestModule.Query.list_order_bys(%{order_bys: [desc: :required_field0]})

    assert get_data.required_field0 == data1.required_field0
    assert get_data.required_field1 == data1.required_field1
  end

  test "preloads/2", %{data0: data0, parent: parent} do
    assert [get_data, _] = QueryTestModule.Query.list_with_preloads(%{preloads: [:parent]})
    assert get_data.required_field0 == data0.required_field0
    assert get_data.required_field1 == data0.required_field1
    assert get_data.parent.id == parent.id
  end

  test "query_results/2", %{data1: data1} do
    assert %QueryTestModule{} =
             get_data =
             QueryTestModule.Query.get_by_sql(%{required_field0: data1.required_field0})

    assert get_data.required_field0 == data1.required_field0
    assert get_data.required_field1 == data1.required_field1
  end
end
