defmodule Doumi.QueryHelper do
  import Ecto.Query

  defmacro __using__(opts) do
    original_module = opts |> Keyword.fetch!(:of) |> Macro.expand(__ENV__)
    Module.put_attribute(__CALLER__.module, :original_module, original_module)

    quote do
      import unquote(__MODULE__)
      import Ecto.Query
    end
  end

  defmacro defquery(:get, repo) do
    original_module = Module.get_attribute(__CALLER__.module, :original_module)
    primary_keys = original_module.__schema__(:primary_key)
    call_args = Enum.map(primary_keys, &Macro.var(&1, original_module))
    repo_args = Enum.map(call_args, &{elem(&1, 0), &1})

    quote do
      def get(unquote_splicing(call_args)) do
        apply(unquote(repo), :get_by, [unquote(original_module), unquote(repo_args)])
      end
    end
  end

  defmacro defquery(:get_by, repo) do
    quote do
      def get_by(params) do
        @original_module
        |> unquote(repo).get_by(params)
      end
    end
  end

  defmacro defquery(:list, repo) do
    quote do
      def list() do
        @original_module
        |> unquote(repo).all()
      end
    end
  end

  defmacro defquery(:create, repo) do
    quote do
      def create(attrs) do
        struct(@original_module)
        |> @original_module.changeset_create(attrs)
        |> unquote(repo).insert()
      end
    end
  end

  defmacro defquery(:update) do
    quote do
      def update(%@original_module{} = model, attrs) do
        model
        |> changeset_update(attrs)
        |> Repo.update()
      end
    end
  end

  defmacro defquery(:delete) do
    quote do
      def delete(%@original_module{} = model) do
        model
        |> Repo.delete()
      end
    end
  end

  defmacro defquery(:count) do
    quote do
      def count() do
        @original_module
        |> select(count())
        |> Repo.one()
      end
    end
  end

  defmacro defsubquery(param_name, operator_atom, field \\ nil)

  defmacro defsubquery(param_name, :contains, field) do
    field = field || param_name

    quote do
      defp unquote(:"subquery_#{param_name}")(query, %{unquote(param_name) => param})
           when not is_nil(param),
           do:
             query
             |> where([q], ilike(q.unquote(field), ^"%#{param}%"))

      defp unquote(:"subquery_#{param_name}")(query, _params), do: query
    end
  end

  defmacro defsubquery(param_name, operator_atom, field) do
    operator =
      case operator_atom do
        :eq -> :==
        :gt -> :>
        :lt -> :<
        :ge -> :>=
        :le -> :<=
        :in -> :in
      end

    field = field || param_name

    quote do
      defp unquote(:"subquery_#{param_name}")(query, %{unquote(param_name) => param})
           when not is_nil(param),
           do: query |> where([q], unquote(operator)(q.unquote(field), ^param))

      defp unquote(:"subquery_#{param_name}")(query, _params), do: query
    end
  end

  defmacro defsubquery(param_name, :between, min_field, max_field) do
    quote do
      defp unquote(:"subquery_#{param_name}")(query, %{unquote(param_name) => param})
           when not is_nil(param),
           do:
             query
             |> where([q], q.unquote(min_field) <= ^param and ^param <= q.unquote(max_field))

      defp unquote(:"subquery_#{param_name}")(query, _params), do: query
    end
  end

  def limit_size(query, params, max_size \\ 30) do
    case params |> Map.get(:size) do
      nil -> query |> limit(^max_size)
      size when size > max_size -> query |> limit(^max_size)
      size -> query |> limit(^size)
    end
  end

  def page(query, params, per_page \\ 30) do
    case params |> Map.get(:page) do
      nil ->
        query

      page ->
        per_page = params |> Map.get(:per_page, per_page)
        offset = per_page * page
        query |> offset(^offset) |> limit(^per_page)
    end
  end

  def order_bys(query, params, default \\ []) do
    case params |> Map.get(:order_bys, default) do
      [] -> query
      order_bys -> query |> order_by(^order_bys)
    end
  end

  def preloads(query, params) do
    case params |> Map.get(:preloads, []) do
      [] -> query
      preloads -> query |> preload(^preloads)
    end
  end

  def query_results(%{columns: columns, rows: rows}, module \\ nil) do
    columns = columns |> Enum.map(&String.to_existing_atom/1)

    results =
      rows
      |> Enum.map(fn row ->
        Enum.zip(columns, row) |> Enum.into(%{})
      end)

    case module do
      module when is_atom(module) and not is_nil(module) ->
        results |> Enum.map(&struct(module, &1))

      _ ->
        results
    end
  end
end
