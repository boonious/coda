defmodule Coda.OnThisDay do
  @moduledoc """
  Render on this day analytics in Livebook.
  """

  use Coda.Livebook.Base

  import Coda.Analytics.OnThisDay
  import Explorer.Series, only: [not_equal: 2]

  alias Explorer.DataFrame

  @impl true
  def overview(stats, opts) do
    Kino.Markdown.new("""
    ###
    ### On #{Date.utc_today() |> Calendar.strftime("%B %d")}
    """)
    |> Kino.render()

    super(stats, opts)
  end

  def render_overview(%DataFrame{} = df), do: df |> digest() |> overview([])
  def render_overview({df, new_facet_df}), do: digest(df, new_facet_df) |> overview([])

  def render_most_played(df) do
    not_untitled_albums = &not_equal(&1["album"], "")

    [
      {
        "<< Artists >>",
        [
          top_artists(df, rows: 8) |> render_facets(title: "most played"),
          top_artists(df, rows: 8, sort: :freq) |> render_facets(title: "most freq (years)"),
          sample_artists(df, rows: 8, counts: 1) |> render_facets(title: "played once (sample)")
        ]
        |> Kino.Layout.grid(columns: 3)
      },
      {
        "<< Albums >>",
        [
          top_albums(df, rows: 8, filter: not_untitled_albums) |> render_facets(title: "most played"),
          top_albums(df, rows: 8, sort: :freq, filter: not_untitled_albums) |> render_facets(title: "most freq (years)"),
          sample_albums(df, rows: 8, counts: 1, filter: not_untitled_albums) |> render_facets(title: "played once (sample)")
        ]
        |> Kino.Layout.grid(columns: 3)
      },
      {
        "<< Tracks >>",
        [
          top_tracks(df, rows: 8) |> render_facets(title: "most played"),
          top_tracks(df, rows: 8, sort: :freq) |> render_facets(title: "most freq (years)"),
          sample_tracks(df, rows: 8, counts: 1) |> render_facets(title: "played once (sample)")
        ]
        |> Kino.Layout.grid(columns: 3)
      }
    ]
    |> Kino.Layout.tabs()
  end
end
