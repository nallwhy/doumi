use Mix.Config

config :doumi, Doumi.TestRepo,
  hostname: "localhost",
  username: "postgres",
  database: "doumi_test",
  port: 45432,
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn
