defmodule Doumi.TestRepo do
  use Ecto.Repo, otp_app: :doumi, adapter: Ecto.Adapters.Postgres

  @impl true
  def prepare_query(_operation, query, opts) do
    if opts[:crash] do
      raise "crash"
    end

    {query, opts}
  end

  @impl true
  def default_options(_operation) do
    [crash: false]
  end
end
