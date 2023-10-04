defmodule Coda.Livebook.Base do
  @moduledoc false

  alias Explorer.DataFrame
  alias Explorer.Series
  alias VegaLite, as: Vl

  import Coda.Analytics.LastfmArchive.FacetConfigs,
    only: [facets: 0, facet_singular: 1, facets_singular: 0]

  require Explorer.DataFrame

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour Coda.Behaviour.Livebook
      import Coda.Livebook.Base

      @impl true
      def overview(stats, _opts \\ []) do
        scrobbles_overview(stats) |> Kino.render()

        [
          years_digest(stats.years_digest),
          facets_digest(stats)
        ]
        |> Kino.Layout.grid(columns: 2)
      end

      defp scrobbles_overview(stats) do
        Kino.Markdown.new("""
        **#{stats.counts}** scrobbles,
        over **#{stats.n_years}** years,
        **#{stats.min_year}** - **#{stats.max_year}**:
        ###
        """)
      end

      defp facets_digest(stats) do
        for type <- facets() do
          pcent = fn x -> (x / stats[:"n_#{type}"] * 100) |> round() end

          """
          - **#{stats[:"n_#{type}"]}** #{type}
          #{facet_digest(stats, type, pcent)}
          """
        end
        |> Enum.join()
        |> Kino.Markdown.new()
      end

      defp facet_digest(%{top_facets: f, played_once_facets: p, new_facets: n}, type, perc_fun) do
        """
          - **#{perc_fun.(p[type][:counts])}%** <small> played once</small>, **#{perc_fun.(n[type][:counts])}%** <small> for the first time</small>
          - <small>top</small> **#{hd(f[type])[facet_singular(type)]}** <sup>#{hd(f[type])[:counts]}x</sup>
        """
      end

      defp facet_digest(%{top_facets: f, played_once_facets: p}, type, perc_fun) do
        """
          - **#{perc_fun.(p[type][:counts])}%** <small> played once</small>
          - <small>top</small> **#{hd(f[type])[facet_singular(type)]}** <sup>#{hd(f[type])[:counts]}x</sup>
        """
      end

      defp years_digest(stats) do
        Vl.new(padding: [left: 75])
        |> Vl.data_from_values(stats)
        |> Vl.mark(:arc, inner_radius: 75, outer_radius: 150, tooltip: true)
        |> Vl.encode_field(:theta, "counts", type: :quantitative)
        |> Vl.encode_field(:color, "year", type: :ordinal, scale: [scheme: "turbo"], legend: nil)
      end

      @impl true
      def render_facets({facets, type, scrobbles}, opts \\ []) do
        title = Keyword.get(opts, :title, "#{type}s")

        [
          "#### ",
          "#### #{title}",
          for {%{"counts" => count} = facet, index} <-
                facets |> DataFrame.to_rows() |> Enum.with_index() do
            value = facet[type |> to_string()]

            "#{index + 1}. **#{value}** <sup>#{count}x</sup> <br/>" <>
              more_info(scrobbles, value, type, opts)
          end
        ]
        |> List.flatten()
        |> Enum.join("\n")
        |> Kino.Markdown.new()
      end

      defoverridable overview: 2, render_facets: 2
    end
  end

  def more_info(scrobbles, value, type, opts) do
    scrobbles = scrobbles |> DataFrame.filter(col(^type) == ^value)

    [
      "<small>#{more_info(scrobbles, type) |> Enum.join(", ")}</small>",
      year_counts(scrobbles)
      |> render_years(new_facet_view: Keyword.get(opts, :new_facet_view, false))
    ]
    |> Enum.join("<br/>")
  end

  defp more_info(scrobbles, :track) do
    other_facets = facets_singular() |> List.delete(:track)

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
    more_info(scrobbles, facets_singular() |> List.delete(type))
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

  defp year_counts(%DataFrame{} = scrobbles) do
    scrobbles
    |> DataFrame.frequencies(["year"])
    |> DataFrame.to_rows()
  end

  defp render_years(year_counts, new_facet_view: false) do
    for(%{"year" => year} <- year_counts, do: "<small>#{year}</small>") |> Enum.join(", ")
  end

  defp render_years(year_counts, new_facet_view: true) do
    %{"year" => year, "counts" => counts} = year_counts |> hd
    "<small>#{year}</small> <sup>#{counts}x</sup>"
  end
end
