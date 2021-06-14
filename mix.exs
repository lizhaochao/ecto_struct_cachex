defmodule EctoStructCachex.MixProject do
  use Mix.Project

  @version "0.2.2"
  @description "in-memory cache for ecto struct."

  @gitee_repo_url "https://gitee.com/lizhaochao/ecto_struct_cachex"
  @github_repo_url "https://github.com/lizhaochao/ecto_struct_cachex"

  @format_cmd "format --dot-formatter=.special_formatter.exs"

  def project do
    [
      app: :ecto_struct_cachex,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Test
      test_pattern: "*_test.exs",

      # Hex
      package: package(),
      description: @description,

      # Docs
      name: "ecto_struct_cachex",
      docs: [main: "ESC"]
    ]
  end

  def application,
    do: [
      extra_applications: [:logger],
      mod: {EctoStructCachex.Application, []}
    ]

  defp package,
    do: [
      name: "ecto_struct_cachex",
      maintainers: ["lizhaochao"],
      licenses: ["MIT"],
      links: %{"Gitee" => @gitee_repo_url, "GitHub" => @github_repo_url}
    ]

  defp deps,
    do: [
      {:decorator, "~> 1.4.0"},
      # Dev and test dependencies
      {:excoveralls, "~> 0.14.0", only: :test},
      {:propcheck, "~> 1.4.0", only: :test},
      {:credo, "~> 1.5.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24.2", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      {:benchfella, "~> 0.3.5", only: :dev}
    ]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
  defp aliases, do: [test: [@format_cmd, "test"], bench: [@format_cmd, "bench"]]
end
