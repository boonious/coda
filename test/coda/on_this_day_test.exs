defmodule Coda.OnThisDayTest do
  use ExUnit.Case, async: true

  import Fixtures.Archive
  import Fixtures.Lastfm

  alias Explorer.DataFrame
  alias Coda.OnThisDay

  setup_all do
    %{
      dataframe:
        "a_user" |> recent_tracks_on_this_day() |> dataframe() |> DataFrame.rename(name: "track")
    }
  end

  test "render_overview/1", %{dataframe: df} do
    assert %Kino.Markdown{content: content} = OnThisDay.render_overview(df)
    assert content =~ "**1** scrobbles"
  end

  test "render_most_played/1", %{dataframe: df} do
    assert %Kino.Layout{} = OnThisDay.render_most_played(df)
  end
end
