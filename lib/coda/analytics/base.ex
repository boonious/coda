defmodule Coda.Analytics.Base do
  @moduledoc false

  import Coda.FacetSettings
  alias Explorer.DataFrame
  alias Explorer.Series

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour Coda.Behaviour.Analytics

      import Coda.Analytics.Commons,
        only: [
          create_group_stats: 2,
          create_facet_stats: 2,
          frequencies: 3,
          most_played: 2,
          sample: 2
        ]

      @impl true
      def digest(df) do
        for {column, series} <- df |> DataFrame.collect() |> DataFrame.to_series(atom_keys: true),
            into: %{} do
          case series |> Series.dtype() do
            :string ->
              {column, %{count: series |> Series.distinct() |> Series.count()}}

            _ ->
              {column,
               %{
                 count: series |> Series.distinct() |> Series.count(),
                 max: series |> Series.max(),
                 min: series |> Series.min()
               }}
          end
        end
      end

      for facet <- Keyword.fetch!(opts, :facets) do
        @impl true
        def unquote(:"top_#{facet}s")(df, options \\ []) do
          facet = unquote(facet)
          group = [facet, :year]
          opts = Keyword.validate!(options, default_opts())

          df
          |> frequencies(group, filter: opts[:filter])
          |> create_group_stats(facet)
          |> most_played(opts)
          |> create_facet_stats(df)
        end

        @impl true
        def unquote(:"sample_#{facet}s")(df, options \\ []) do
          facet = unquote(facet)
          opts = Keyword.validate!(options, default_opts())

          df
          |> frequencies([facet], counts: opts[:counts])
          |> sample(rows: opts[:rows])
          |> create_facet_stats(df)
        end

        defoverridable [{:"top_#{facet}s", 2}, {:"sample_#{facet}s", 2}]
      end
    end
  end
end
