defmodule Coda.Livebook.BaseTest do
  use ExUnit.Case, async: true

  alias Coda.Analytics
  alias Coda.Analytics.LastfmArchive.FacetConfigs
  alias Coda.Livebook.Base

  @test_livebook Module.concat(Base, Test)
  defmodule @test_livebook, do: use(Base)

  @test_analytics Module.concat(Base, Analytics.Test)

  defmodule @test_analytics do
    use Coda.Analytics.Base, facets: Coda.Analytics.LastfmArchive.FacetConfigs.facets()

    @impl true
    def dataframe(_opts), do: Coda.Factory.dataframe()
  end

  test "overview/1" do
    stats = @test_analytics.dataframe([]) |> @test_analytics.digest()
    assert %Kino.Layout{} = @test_livebook.overview(stats)
  end

  for facet <- FacetConfigs.facets() do
    test "render_facets/2 #{facet}" do
      df = @test_analytics.dataframe([])
      facet = unquote(facet)
      facets_data = apply(@test_analytics, :"top_#{facet}", [df])
      assert %Kino.Markdown{} = @test_livebook.render_facets(facets_data, [])
    end
  end
end
