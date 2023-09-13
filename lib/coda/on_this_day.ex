defmodule Coda.OnThisDay do
  @moduledoc """
  Render on this day analytics in Livebook.
  """

  use Coda.Livebook.Base, facets: Coda.FacetSettings.facets()

  import Coda.Analytics.OnThisDay
  import Explorer.Series, only: [not_equal: 2]

  alias Explorer.DataFrame

  def render_overview(%DataFrame{} = df), do: df |> digest() |> overview()

  def render_most_played(df) do
    not_untitled_albums = &not_equal(&1["album"], "")

    [
      {
        "<< most plays >>",
        [
          top_artists(df, rows: 8) |> render_facets(),
          top_albums(df, rows: 8, filter: not_untitled_albums) |> render_facets(),
          top_tracks(df, rows: 8) |> render_facets()
        ]
        |> Kino.Layout.grid(columns: 3)
      },
      {
        "<< most frequent over the years >>",
        [
          top_artists(df, rows: 8, sort: :freq) |> render_facets(),
          top_albums(df, rows: 8, sort: :freq, filter: not_untitled_albums) |> render_facets(),
          top_tracks(df, rows: 8, sort: :freq) |> render_facets()
        ]
        |> Kino.Layout.grid(columns: 3)
      },
      {
        "<< play once samples >>",
        [
          sample_artists(df, rows: 8, counts: 1) |> render_facets(),
          sample_albums(df, rows: 8, counts: 1, filter: not_untitled_albums) |> render_facets(),
          sample_tracks(df, rows: 8, counts: 1) |> render_facets()
        ]
        |> Kino.Layout.grid(columns: 3)
      }
    ]
    |> Kino.Layout.tabs()
  end
end
