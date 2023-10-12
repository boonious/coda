defmodule Coda.Analytics.BaseTest do
  use ExUnit.Case, async: true

  alias Coda.Analytics.Base
  alias Coda.Analytics.LastfmArchive.FacetConfigs

  alias Explorer.DataFrame
  alias Explorer.Series

  @test_analytics Module.concat(Base, Test)

  defmodule @test_analytics do
    use Base, facets: Coda.Analytics.LastfmArchive.FacetConfigs.facets()
    import Coda.Factory
    alias Explorer.DataFrame

    @impl true
    def dataframe(_opts), do: build(:scrobbles, rows: 1) |> Coda.Factory.dataframe()
  end

  for facet <- FacetConfigs.facets() do
    test "top_#{facet}/2" do
      df = @test_analytics.dataframe([])
      facet = unquote(facet |> FacetConfigs.facet_singular())

      assert {facets, ^facet, scrobbles} = apply(@test_analytics, :"top_#{facet}s", [df])
      assert (facet |> to_string()) in (facets |> DataFrame.names())
      assert "counts" in (facets |> DataFrame.names())
      assert facets["counts"] |> Series.to_list() == [1]

      assert %DataFrame{} = df = scrobbles
      assert df |> DataFrame.shape() == {1, 15}
    end

    test "sample_#{facet}/2" do
      df = @test_analytics.dataframe([])
      facet = unquote(facet |> FacetConfigs.facet_singular())

      assert {facets, ^facet, scrobbles} =
               apply(@test_analytics, :"sample_#{facet}s", [df, [rows: 1]])

      assert (facet |> to_string()) in (facets |> DataFrame.names())
      assert "counts" in (facets |> DataFrame.names())
      assert facets["counts"] |> Series.to_list() == [1]

      assert %DataFrame{} = df = scrobbles
      assert df |> DataFrame.shape() == {1, 15}
    end
  end
end
