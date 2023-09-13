defmodule Coda.OnThisDayTest do
  use ExUnit.Case, async: true
  import Coda.Factory

  alias Explorer.DataFrame
  alias Coda.OnThisDay

  setup_all do
    %{
      dataframe:
        build(:scrobbles, rows: 10)
        |> Enum.map(&Map.from_struct/1)
        |> DataFrame.new(lazy: true)
        |> DataFrame.rename(name: "track")
    }
  end

  test "render_overview/1", %{dataframe: df} do
    assert %Kino.Markdown{content: content} = OnThisDay.render_overview(df)
    assert content =~ "**10** scrobbles"
  end

  test "render_most_played/1", %{dataframe: df} do
    assert %Kino.Layout{} = OnThisDay.render_most_played(df)
  end
end
