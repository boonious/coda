defmodule Coda.Analytics.BaseTest do
  use ExUnit.Case, async: true

  alias Coda.Analytics.OnThisDay
  alias Coda.FacetSettings

  alias Explorer.DataFrame
  alias Explorer.Series

  import Fixtures.Archive
  import Fixtures.Lastfm

  setup_all do
    %{
      data_frame:
        "a_user" |> recent_tracks_on_this_day() |> dataframe() |> DataFrame.rename(name: "track")
    }
  end

  for facet <- FacetSettings.facets() do
    test "top_#{facet}s/2", %{data_frame: df} do
      facet = "#{unquote(facet)}"
      assert {%DataFrame{} = df_facets, facet_stats} = apply(OnThisDay, :"top_#{facet}s", [df])

      assert facet in (df_facets |> DataFrame.names())
      assert "year" not in (df_facets |> DataFrame.names())
      assert df_facets["2023"] |> Series.to_list() == [1]
      assert df_facets["years_freq"] |> Series.to_list() == [1]
      assert df_facets["total_plays"] |> Series.to_list() == [1]

      assert %{0 => %DataFrame{} = _stats} = facet_stats
      # more test required for stats later
    end
  end
end
