defmodule Doumi.MixProject do
  use Mix.Project

  def project do
    [
      app: :doumi,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.2 or ~> 3.0", optional: true},
      {:ecto_sql, "~> 3.0", optional: true},
      {:postgrex, "~> 0.15.0", only: :test}
    ]
  end
end
