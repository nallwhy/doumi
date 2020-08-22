use Mix.Config

config :doumi, Doumi.TestRepo,
  hostname: "localhost",
  username: "postgres",
  database: "doumi_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn
