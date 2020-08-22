defmodule Doumi.RepoHelperTest do
  use Doumi.EctoCase, async: true
  import Ecto.Query
  alias Doumi.RepoHelper
  alias Doumi.TestRepo

  describe "wrap_transcation" do
    test "returns {:ok, result} with ok" do
      assert {:ok, 1} = RepoHelper.wrap_transaction(fn ->
        {num_rows, _} = TestRepo.insert_all("repo_tests", [%{field0: 1}])
        {:ok, num_rows}
      end, TestRepo)

      assert 1 = TestRepo.one(from r in "repo_tests", where: [field0: 1], select: r.field0)
    end

    test "rollbacks and returns {:error, reason} with error" do
      assert {:error, :unknown_error} = RepoHelper.wrap_transaction(fn ->
        {_num_rows, _} = TestRepo.insert_all("repo_tests", [%{field0: 1}])
        {:error, :unknown_error}
      end, TestRepo)

      assert TestRepo.one(from r in "repo_tests", where: [field0: 1], select: r.field0) == nil
    end
  end
end
