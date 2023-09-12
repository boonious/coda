defmodule Coda.Livebook.Base do
  @moduledoc false

  alias Explorer.DataFrame
  alias Explorer.Series

  import Coda.FacetSettings, only: [facets: 0]
  require Explorer.DataFrame

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour Coda.Behaviour.Livebook
      import Coda.Livebook.Base

      @impl true
      def overview(stats) do
        Kino.Markdown.new("""
        ###
        There are **#{stats.id.count}** scrobbles on **#{Date.utc_today() |> Calendar.strftime("%B %d")}**,
        over **#{stats.year.count}** years
        (**#{stats.year.min}** - **#{stats.year.max}**):
        - **#{stats.album.count}** albums, **#{stats.artist.count}** artists, **#{stats.track.count}** tracks
        <br/><br/>
        """)
      end

      @impl true
      def render_facets({facets, facet_type, scrobbles}, options \\ []) do
        [
          "#### ",
          "#### #{"#{facet_type}" |> String.capitalize()}s",
          for {%{"counts" => count} = facet, index} <-
                facets |> DataFrame.to_rows() |> Enum.with_index() do
            facet_value = facet[facet_type |> to_string()]

            "#{index + 1}. **#{facet_value}** <sup>#{count}x</sup> <br/>" <>
              more_info({scrobbles, facet_value, facet_type})
          end
        ]
        |> List.flatten()
        |> Enum.join("\n")
        |> Kino.Markdown.new()
      end

      defoverridable overview: 1, render_facets: 2
    end
  end

  def more_info({scrobbles, value, type}) do
    scrobbles = scrobbles |> DataFrame.filter(col(^type) == ^value)

    [
      "<small>#{more_info(scrobbles, type) |> Enum.join(", ")}</small>",
      for(year <- years(scrobbles), do: "<small>#{year}</small>") |> Enum.join(", ")
    ]
    |> Enum.join("<br/>")
  end

  defp more_info(scrobbles, :track) do
    other_facets = facets() |> List.delete(:track)
    scrobbles = scrobbles |> DataFrame.distinct(other_facets)

    case scrobbles |> DataFrame.shape() do
      {rows, _} when rows <= 2 ->
        [
          for %{"album" => album, "artist" => artist} <- scrobbles |> DataFrame.to_rows() do
            "#{album} by #{artist}"
          end
          |> Enum.join("<br/>")
        ]

      _ ->
        more_info(scrobbles, other_facets)
    end
  end

  defp more_info(scrobbles, type) when is_atom(type) do
    more_info(scrobbles, facets() |> List.delete(type))
  end

  defp more_info(scrobbles, facets) when is_list(facets) do
    for f <- facets do
      col = scrobbles |> DataFrame.distinct([f]) |> Access.get(f)
      "#{facet(f, col |> Series.count(), col)}"
    end
  end

  defp facet(:artist, count, _col) when count > 3, do: "#{count} various artists"
  defp facet(:artist, 1, col), do: "by #{col[0]}"
  defp facet(_type, 1, col), do: col[0]
  defp facet(type, count, _col), do: "#{count} #{type}s"

  defp years(%DataFrame{} = scrobbles) do
    scrobbles
    |> DataFrame.distinct(["year"])
    |> Access.get("year")
    |> Series.distinct()
    |> Series.to_list()
  end
end
