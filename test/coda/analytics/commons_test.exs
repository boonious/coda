defmodule Coda.Analytics.CommonsTest do
  use ExUnit.Case, async: true
  import Coda.Factory

  alias Explorer.DataFrame
  alias Explorer.Series
  alias Coda.Analytics.Commons

  setup_all do
    # 5 scrobbles from a same artist
    %{dataframe: build(:scrobbles, rows: 5, artist: "SZA") |> dataframe()}
  end

  describe "frequencies/2" do
    test "for a data frame", %{dataframe: df} do
      facet = ["artist", "year"]

      assert %DataFrame{} = df = Commons.frequencies(df, facet) |> DataFrame.collect()
      assert df |> DataFrame.names() == facet ++ ["counts"]
      assert df["counts"] |> Series.to_list() == [5]
    end

    test "filter option to exclude untitled albums" do
      df =
        build(:scrobbles, rows: 5, artist: "SZA", album: "")
        |> Enum.map(&Map.from_struct/1)
        |> DataFrame.new(lazy: true)
        |> DataFrame.rename(name: "track")

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
