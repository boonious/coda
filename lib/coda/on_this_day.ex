defmodule Coda.OnThisDay do
  @moduledoc """
  Render on this day analytics in Livebook.
  """

  use Coda.Livebook.Base

  import Coda.Analytics.OnThisDay
  import Explorer.Series, only: [not_equal: 2]

  alias Coda.Analytics.OnThisDay, as: OTDA
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

  # from try/rescue clause pending better error handling from LastfmArchive
  def render_overview(nil), do: {:error, :einval}
  def render_overview({nil, nil}), do: {:error, :einval}

  def render_overview(%DataFrame{} = df), do: digest(df) |> overview([])
  def render_overview({df, new_facet_df}), do: digest(df, new_facet_df) |> overview([])

  def render_most_played(nil), do: {:error, :einval}

  def render_most_played(df) do
    for facet <- [:artists, :albums, :tracks] do
      filter = if facet == :albums, do: [filter: &not_equal(&1["album"], "")], else: []

      top_facets = apply(OTDA, :"top_#{facet}", [df, [rows: 8] ++ filter])
      top_facets_freq = apply(OTDA, :"top_#{facet}", [df, [rows: 8, sort: :freq] ++ filter])
      samples = apply(OTDA, :"sample_#{facet}", [df, [rows: 8, counts: 1] ++ filter])

      {
        "<< #{facet} >>",
        [
          top_facets |> render_facets(title: "most played"),
          top_facets_freq |> render_facets(title: "most freq (years)"),
          samples |> render_facets(title: "played once (sample)")
        ]
        |> Kino.Layout.grid(columns: 3)
      }
    end
    |> Kino.Layout.tabs()
  end

  def render_new_on_this_day(nil), do: {:error, :einval}

  def render_new_on_this_day(new_facet_dfs, scrobbles) do
    OTDA.collect_new_facets(new_facet_dfs, scrobbles, rows: 8)
    |> Enum.map(&render_facets(&1, new_facet_view: true))
    |> Kino.Layout.grid(columns: 3)
  end
end
