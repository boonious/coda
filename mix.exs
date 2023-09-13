defmodule Coda.MixProject do
  use Mix.Project

  @description """
  Analytics and visualisation of Lastfm music listening history 听歌历史.
  """

  def project do
    [
      app: :coda,
      version: "0.2.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "coda",
      description: @description,
      package: package(),
      source_url: "https://github.com/boonious/coda",
      homepage_url: "https://github.com/boonious/coda",
      docs: [
        main: "readme",
        extras: [
          "README.md",
          "CHANGELOG.md",
          "livebook/on_this_day.livemd": [title: "On this day ♫"]
        ],
        groups_for_extras: [
          Analytics: Path.wildcard("livebook/*.livemd")
        ],
        assets: "assets",
        source_ref: "master"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "test/fixtures", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:lastfm_archive, "~> 1.1"},
      {:explorer, "~> 0.7"},

      # test and dev only
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:ex_machina, "~> 2.7", only: :test},
      {:hammox, "~> 0.7", only: :test}
    ]
  end

  defp package do
    [
      name: "coda",
      maintainers: ["Boon Low"],
      licenses: ["Apache 2.0"],
      links: %{
        Changelog: "https://github.com/boonious/coda/blob/master/CHANGELOG.md",
        GitHub: "https://github.com/boonious/coda"
      }
    ]
  end
end
