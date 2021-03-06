defmodule Doumi.TestRepo.Migrations.MigrateAll do
  use Ecto.Migration

  def change do
    create table(:ecto_case_tests, primary_key: false) do
      add :required_field0, :integer, primary_key: true
      add :required_field1, :integer, primary_key: true
      add :not_required_field0, :integer
    end

    create table(:repo_tests) do
      add :field0, :integer
    end

    create table(:query_test_parents) do
    end

    create table(:query_tests, primary_key: false) do
      add :required_field0, :integer, primary_key: true
      add :required_field1, :integer, primary_key: true
      add :not_required_field0, :string
      add :parent_id, references(:query_test_parents)
    end
  end
end
