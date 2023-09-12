defmodule Coda.Livebook.BaseTest do
  use ExUnit.Case, async: true

  import Fixtures.Archive
  import Fixtures.Lastfm

  alias Coda.Analytics
  alias Coda.FacetSettings
  alias Coda.Livebook.Base

  alias Explorer.DataFrame

  @test_livebook Module.concat(Base, Test)
  defmodule @test_livebook, do: use(Base)

  @test_analytics Module.concat(Base, Analytics.Test)

  defmodule @test_analytics do
    use Coda.Analytics.Base, facets: Coda.FacetSettings.facets()

    @impl true
    def dataframe(_opts), do: Fixtures.Archive.dataframe()
  end

  setup_all do
    df = "a_user" |> recent_tracks_on_this_day() |> dataframe() |> DataFrame.rename(name: "track")
    %{dataframe: df}
  end

  test "overview/1", %{dataframe: df} do
    stats = @test_analytics.digest(df)
    assert %Kino.Markdown{content: _content} = @test_livebook.overview(stats)
  end

  for facet <- FacetSettings.facets() do
    test "render_facets/2 #{facet}", %{dataframe: df} do
      facet = unquote(facet)
      facets_data = apply(@test_analytics, :"top_#{facet}s", [df])
      assert %Kino.Markdown{content: _content} = @test_livebook.render_facets(facets_data, [])
    end
  end
end
