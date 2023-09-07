defmodule Coda.OnThisDay do
  @moduledoc """
  Create on this day analytics and display them in Livebook.
  """

  use Coda.Behaviour.Livebook, facets: Coda.FacetSettings.facets()

  import Coda.Analytics.OnThisDay
  import Explorer.Series, only: [not_equal: 2]

  def render_overview(%Explorer.DataFrame{} = df) do
    df
    |> digest()
    |> overview_ui()
  end

  def render_most_played(df) do
    not_untitled_albums = &not_equal(&1["album"], "")

    [
      {
        "<< most plays >>",
        [
          top_artists(df, rows: 8) |> most_played_ui(),
          top_albums(df, rows: 8, filter: not_untitled_albums) |> most_played_ui(),
          top_tracks(df, rows: 8) |> most_played_ui()
        ]
        |> Kino.Layout.grid(columns: 3)
      },
      {
        "<< most frequent over the years >>",
        [
          top_artists(df, rows: 8, sort_by: "years_freq") |> most_played_ui(),
          top_albums(df, rows: 8, sort_by: "years_freq", filter: not_untitled_albums)
          |> most_played_ui(),
          top_tracks(df, rows: 8, sort_by: "years_freq") |> most_played_ui()
        ]
        |> Kino.Layout.grid(columns: 3)
      },
      {
        "<< play once samples >>",
        [
          sample_artists(df, rows: 8, counts: 1) |> most_played_ui(),
          sample_albums(df, rows: 8, counts: 1, filter: not_untitled_albums) |> most_played_ui(),
          sample_tracks(df, rows: 8, counts: 1) |> most_played_ui()
        ]
        |> Kino.Layout.grid(columns: 3)
      }
    ]
    |> Kino.Layout.tabs()
  end
end
