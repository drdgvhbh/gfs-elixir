defmodule GfsUmbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      test_paths: test_paths(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp test_paths do
    "apps/*/test" |> Path.wildcard() |> Enum.sort()
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:excoveralls, "~> 0.7", only: :test}
    ]
  end
end
