defmodule Doumi.MixProject do
  use Mix.Project

  @version "0.2.2"
  @project_url "https://github.com/nallwhy/doumi"

  def project do
    [
      app: :doumi,
      version: @version,
      elixir: ">= 1.7.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "A collection of useful helpers for Elixir",
      source_url: @project_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:ecto, "~> 2.2 or ~> 3.0", optional: true},
      {:ecto_sql, "~> 3.0", optional: true},
      {:postgrex, "~> 0.15.0", only: :test}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url},
      maintainers: ["Jinkyou Son(nallwhy@gmail.com)"]
    ]
  end

  defp docs() do
    [main: "readme", extras: ["README.md"]]
  end
end
