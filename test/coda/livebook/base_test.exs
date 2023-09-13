defmodule Coda.Livebook.BaseTest do
  use ExUnit.Case, async: true

  alias Coda.Analytics
  alias Coda.FacetSettings
  alias Coda.Livebook.Base

  @test_livebook Module.concat(Base, Test)
  defmodule @test_livebook, do: use(Base)

  @test_analytics Module.concat(Base, Analytics.Test)

  defmodule @test_analytics do
    use Coda.Analytics.Base, facets: Coda.FacetSettings.facets()

    @impl true
    def dataframe(_opts), do: Coda.Factory.dataframe()
  end

  test "overview/1" do
    stats = @test_analytics.dataframe([]) |> @test_analytics.digest()
    assert %Kino.Markdown{content: _content} = @test_livebook.overview(stats)
  end

  for facet <- FacetSettings.facets() do
    test "render_facets/2 #{facet}" do
      df = @test_analytics.dataframe([])
      facet = unquote(facet)
      facets_data = apply(@test_analytics, :"top_#{facet}s", [df])
      assert %Kino.Markdown{content: _content} = @test_livebook.render_facets(facets_data, [])
    end
  end
end
