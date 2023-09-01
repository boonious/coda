defmodule Coda.OnThisDay do
  @moduledoc """
  Create on this day analytics and display them in Livebook.
  """

  # these concerns and the analytics and UI functions in this module needs splitting up
  use Coda.Behaviour.Analytics, facets: Coda.Settings.facets()
  use Coda.Behaviour.Livebook, facets: Coda.Settings.facets()

  require Explorer.DataFrame
  alias Explorer.DataFrame

  import Explorer.Series, only: [not_equal: 2]

  def columns, do: ["id", "artist", "datetime", "year", "album", "track", "mmdd"]

  @impl true
  def data_frame(opts \\ []) do
    Keyword.validate!(opts, format: :ipc_stream, facet: :scrobbles, columns: columns())
    |> read_data_frame()
    |> filter_data_frame()
  end

  defp read_data_frame(opts) do
    LastfmArchive.default_user() |> LastfmArchive.read(opts)
  end

  defp filter_data_frame({:ok, df}), do: df |> DataFrame.filter(contains(mmdd, this_day()))
  defp filter_data_frame(error), do: error

  def this_day(format \\ "%m%d"), do: Date.utc_today() |> Calendar.strftime(format)

  def render_overview(%Explorer.DataFrame{} = df) do
    df
    |> data_frame_stats()
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