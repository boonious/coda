defmodule Coda.Analytics.BaseTest do
  use ExUnit.Case, async: true

  alias Coda.Analytics.Base
  alias Coda.FacetSettings

  alias Explorer.DataFrame
  alias Explorer.Series

  import Fixtures.Archive
  import Fixtures.Lastfm

  @test_analytics Module.concat(Base, Test)

  defmodule @test_analytics do
    use Base, facets: Coda.FacetSettings.facets()

    @impl true
    def dataframe(_opts), do: Fixtures.Archive.dataframe()
  end

  setup_all do
    %{
      dataframe:
        "a_user" |> recent_tracks_on_this_day() |> dataframe() |> DataFrame.rename(name: "track")
    }
  end

  for facet <- FacetSettings.facets() do
    test "top_#{facet}s/2", %{dataframe: df} do
      facet = unquote(facet)

      assert {facets, ^facet, scrobbles} = apply(@test_analytics, :"top_#{facet}s", [df])
      assert (facet |> to_string()) in (facets |> DataFrame.names())
      assert "counts" in (facets |> DataFrame.names())
      assert facets["counts"] |> Series.to_list() == [1]

      assert %DataFrame{} = df = scrobbles
      assert df |> DataFrame.shape() == {1, 15}
    end

    test "sample_#{facet}s/2", %{dataframe: df} do
      facet = unquote(facet)

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
