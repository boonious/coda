defmodule Coda.Analytics.LastfmArchive.FacetConfigs do
  @moduledoc false

  def facets, do: facets_columns() |> Map.keys() |> List.delete(:scrobbles)

  def facets_singular, do: facets() |> Enum.map(&facet_singular(&1))

  def facet_singular(type), do: "#{type}" |> String.trim_trailing("s") |> String.to_atom()

  def facet_stats_columns, do: [:first_play, :last_play, :counts]

  def default_opts,
    do: [rows: 5, sort: :counts, filter: nil, counts: -1, rank: :top, more_info: true]

  def facets_columns do
    %{
      scrobbles: [:id, :artist, :datetime, :year, :album, :track, :mmdd],
      artists: [:artist, :year, :mmdd] ++ facet_stats_columns(),
      albums: [:album, :album_mbid, :artist, :year, :mmdd] ++ facet_stats_columns(),
      tracks: [:track, :album, :artist, :mbid, :year, :mmdd] ++ facet_stats_columns()
    }
  end
end
