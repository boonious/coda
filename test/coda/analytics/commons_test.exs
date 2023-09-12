defmodule Coda.Analytics.CommonsTest do
  use ExUnit.Case, async: true

  import Fixtures.Archive
  import Fixtures.Lastfm

  alias Explorer.DataFrame
  alias Explorer.Series
  alias Coda.Analytics.Commons

  setup_all do
    %{dataframe: LastfmArchive.default_user() |> recent_tracks_on_this_day() |> dataframe()}
  end

  describe "frequencies/2" do
    test "for a data frame", %{dataframe: df} do
      facet = ["artist", "year"]

      assert %DataFrame{} = df = Commons.frequencies(df, facet) |> DataFrame.collect()
      assert df |> DataFrame.names() == facet ++ ["counts"]
      assert df["counts"] |> Series.to_list() == [1]
    end

    test "filter option to exclude untitled albums" do
      df = recent_tracks_without_album_title() |> dataframe()
      fun = &Series.not_equal(&1["album"], "")

      assert %DataFrame{} = df = Commons.frequencies(df, "album", filter: fun)
      assert df |> DataFrame.collect() |> DataFrame.pull("album") |> Series.to_list() == []
    end
  end

  test "rank_and_limit/2", %{dataframe: df} do
    df = Commons.frequencies(df, "album")
    assert %DataFrame{} = Commons.rank_and_limit(df) |> DataFrame.collect()
  end
end
