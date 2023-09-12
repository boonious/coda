defmodule Coda.Analytics.Base do
  @moduledoc false

  import Coda.FacetSettings
  alias Explorer.DataFrame
  alias Explorer.Series

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour Coda.Behaviour.Analytics
      import Coda.Analytics.Commons, only: [frequencies: 3, rank_and_limit: 2]

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
          type = unquote(facet)
          opts = Keyword.validate!(options, default_opts())

          df
          |> frequencies(type, filter: opts[:filter], sort: opts[:sort])
          |> rank_and_limit(opts)
          |> DataFrame.collect()
          |> then(fn facets ->
            {facets, type, DataFrame.join(facets, df |> DataFrame.collect())}
          end)
        end

        @impl true
        def unquote(:"sample_#{facet}s")(df, options \\ []) do
          type = unquote(facet)
          opts = Keyword.validate!(options, default_opts())

          df
          |> frequencies(type, filter: opts[:filter], counts: opts[:counts])
          |> DataFrame.collect()
          |> DataFrame.sample(opts[:rows], replace: true)
          |> then(fn facets ->
            {facets, type, DataFrame.join(facets, df |> DataFrame.collect())}
          end)
        end

        defoverridable [{:"top_#{facet}s", 2}, {:"sample_#{facet}s", 2}]
      end
    end
  end
end
