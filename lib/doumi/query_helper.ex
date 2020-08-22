if Code.ensure_loaded?(Ecto) do
  defmodule Doumi.QueryHelper do
    import Ecto.Query

    defmacro __using__(opts) do
      model_module = opts |> Keyword.fetch!(:of) |> Macro.expand(__ENV__)
      Module.put_attribute(__CALLER__.module, :model_module, model_module)

      quote do
        import unquote(__MODULE__)
        import Ecto.Query
      end
    end

    defmacro defquery(type, repo \\ nil)

    defmacro defquery(:get, repo) do
      repo = repo || Application.get_env(:doumi, :default_repo)
      model_module = Module.get_attribute(__CALLER__.module, :model_module)
      primary_keys = model_module.__schema__(:primary_key)
      call_args = Enum.map(primary_keys, &Macro.var(&1, model_module))
      repo_args = Enum.map(call_args, &{elem(&1, 0), &1})

      quote do
        def get(unquote_splicing(call_args)) do
          apply(unquote(repo), :get_by, [unquote(model_module), unquote(repo_args)])
        end
      end
    end

    defmacro defquery(:get_by, repo) do
      repo = repo || Application.get_env(:doumi, :default_repo)

      quote do
        def get_by(params) do
          @model_module
          |> unquote(repo).get_by(params)
        end
      end
    end

    defmacro defquery(:list, repo) do
      repo = repo || Application.get_env(:doumi, :default_repo)

      quote do
        def list() do
          @model_module
          |> unquote(repo).all()
        end
      end
    end

    defmacro defquery(:create, repo) do
      repo = repo || Application.get_env(:doumi, :default_repo)

      quote do
        def create(attrs) do
          struct(@model_module)
          |> @model_module.changeset_create(attrs)
          |> unquote(repo).insert()
        end
      end
    end

    defmacro defquery(:update, repo) do
      repo = repo || Application.get_env(:doumi, :default_repo)

      quote do
        def update(%@model_module{} = model, attrs) do
          model
          |> @model_module.changeset_update(attrs)
          |> unquote(repo).update()
        end
      end
    end

    defmacro defquery(:delete, repo) do
      repo = repo || Application.get_env(:doumi, :default_repo)

      quote do
        def delete(%@model_module{} = model) do
          model
          |> unquote(repo).delete()
        end
      end
    end

    defmacro defquery(:count, repo) do
      repo = repo || Application.get_env(:doumi, :default_repo)

      quote do
        def count() do
          @model_module
          |> select(count())
          |> unquote(repo).one()
        end
      end
    end

    defmacro defsubquery(name, operator_atom, field \\ nil)

    defmacro defsubquery(name, operator_atom, field) when operator_atom in [:like, :ilike] do
      field = field || name

      quote do
        defp unquote(:"subquery_#{name}")(query, %{unquote(name) => param})
             when not is_nil(param),
             do:
               query
               |> where([q], unquote(operator_atom)(q.unquote(field), ^"%#{param}%"))

        defp unquote(:"subquery_#{name}")(query, _params), do: query
      end
    end

    defmacro defsubquery(name, operator_atom, field) do
      operator =
        case operator_atom do
          :eq -> :==
          :gt -> :>
          :ge -> :>=
          :le -> :<=
          :lt -> :<
          :in -> :in
        end

      field = field || name

      quote do
        defp unquote(:"subquery_#{name}")(query, %{unquote(name) => param})
             when not is_nil(param),
             do: query |> where([q], unquote(operator)(q.unquote(field), ^param))

        defp unquote(:"subquery_#{name}")(query, _params), do: query
      end
    end

    defmacro defsubquery(name, :between, min_field, max_field) do
      quote do
        defp unquote(:"subquery_#{name}")(query, %{unquote(name) => param})
             when not is_nil(param),
             do:
               query
               |> where([q], q.unquote(min_field) <= ^param and ^param <= q.unquote(max_field))

        defp unquote(:"subquery_#{name}")(query, _params), do: query
      end
    end

    def limit_size(query, params, max_size \\ 30) do
      case params |> Map.get(:size) do
        nil -> query |> limit(^max_size)
        size when size > max_size -> query |> limit(^max_size)
        size -> query |> limit(^size)
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
        module when not is_nil(module) and is_atom(module) ->
          results |> Enum.map(&struct(module, &1))

        _ ->
          results
      end
    end

    def query_sql(sql, params \\ []) do
      Ecto.Adapters.SQL.query!(__MODULE__, sql, params)
    end
  end
end
