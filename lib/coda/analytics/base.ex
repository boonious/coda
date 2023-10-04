defmodule Coda.Analytics.Base do
  @moduledoc false

  import Coda.Analytics.Commons, only: [frequencies: 3, rank_and_limit: 2]
  import Coda.Analytics.LastfmArchive.FacetConfigs, only: [default_opts: 0, facet_singular: 1]
  alias Explorer.DataFrame
  require Explorer.DataFrame

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour Coda.Behaviour.Analytics

      import Coda.Analytics.Base
      import Coda.Analytics.Commons, only: [frequencies: 2]
      import Coda.Analytics.LastfmArchive.FacetConfigs, only: [facets: 0, facets_singular: 0]
      # import Explorer.Series, only: [not_equal: 2]

      require Explorer.DataFrame

      @impl true
      def digest(df, new_facet_dfs \\ nil) do
        df
        |> DataFrame.summarise(
          counts: count(datetime),
          min_year: min(year),
          max_year: max(year),
          n_artists: n_distinct(artist),
          n_albums: n_distinct(album),
          n_tracks: n_distinct(track),
          n_years: n_distinct(year)
        )
        |> DataFrame.collect()
        |> DataFrame.to_rows(atom_keys: true)
        |> hd()
        |> put_extra_stats(df)
        |> put_new_facets_stats(new_facet_dfs)
      end

      for facet <- Keyword.get(opts, :facets, facets()) do
        @impl true
        def unquote(:"top_#{facet}")(df, opts \\ []), do: top_facets(df, unquote(facet), opts)

        @impl true
        def unquote(:"sample_#{facet}")(df, opts \\ []) do
          top_facets(df, unquote(facet), opts |> Keyword.put(:rank, :sample))
        end

        defoverridable [{:"top_#{facet}", 2}, {:"sample_#{facet}", 2}]
      end

      defdelegate collect_new_facets(dfs, scrobbles, opts), to: Coda.Analytics.Base

      defp put_extra_stats(df, df_source) do
        df
        |> Map.put(:played_once_facets, played_once_facets(df_source))
        |> Map.put(:top_facets, top_facets(df_source))
        |> Map.put(:years_digest, years_digest(df_source))
      end

      defp put_new_facets_stats(df, nil), do: df
      defp put_new_facets_stats(df, dfs), do: df |> Map.put(:new_facets, new_facets(dfs))

      defp new_facets(%{artists: _artists} = dfs) do
        for {facet, df} <- dfs do
          df
          |> DataFrame.collect()
          |> DataFrame.shape()
          |> then(fn {rows, _} -> {facet, %{counts: rows}} end)
        end
      end

      defp new_facets(%{}), do: %{}

      defp played_once_facets(df) do
        for facet <- facets(), into: %{} do
          frequencies(df, facet_singular(facet), counts: 1)
          |> DataFrame.collect()
          |> DataFrame.shape()
          |> then(fn {rows, _} -> {facet, %{counts: rows}} end)
        end
      end

      defp top_facets(df) do
        for facet <- facets(), into: %{} do
          untitled = &Explorer.Series.not_equal(&1["album"], "")
          opts = [rows: 1, more_info: false]
          opts = if facet == :albums, do: opts |> Keyword.put(:filter, untitled), else: opts

          {stats, _facet, _scrobbles} = top_facets(df, facet, opts)
          {facet, stats |> DataFrame.to_rows(atom_keys: true)}
        end
      end

      defp years_digest(df) do
        df
        |> DataFrame.frequencies([:year])
        |> DataFrame.collect()
        |> DataFrame.to_rows(atom_keys: true)
      end
    end
  end

  def top_facets(df, facet_type, options \\ []) do
    opts = Keyword.validate!(options, default_opts())

    df
    |> frequencies(facet_singular(facet_type),
      counts: opts[:counts],
      filter: opts[:filter],
      sort: opts[:sort]
    )
    |> maybe_rank_and_limit(opts, opts[:rank])
    |> maybe_sample(opts[:rows], opts[:rank])
    |> maybe_more_info(df, facet_singular(facet_type), opts[:more_info])
  end

  def collect_new_facets(dfs, scrobbles, opts \\ []) do
    opts = Keyword.validate!(opts, default_opts())

    for {facet, df} <- dfs do
      df =
        case facet == :albums do
          true ->
            df
            |> DataFrame.filter(album != "")
            |> DataFrame.head(opts[:rows])
            |> DataFrame.collect()

          false ->
            df |> DataFrame.head(opts[:rows]) |> DataFrame.collect()
        end

      {df, facet_singular(facet), DataFrame.join(df, scrobbles |> DataFrame.collect())}
    end
  end

  defp maybe_rank_and_limit(df, _opts, :sample), do: df |> DataFrame.collect()
  defp maybe_rank_and_limit(df, opts, :top), do: rank_and_limit(df, opts) |> DataFrame.collect()

  defp maybe_sample(df, _rows, :top), do: df
  defp maybe_sample(df, rows, :sample), do: df |> DataFrame.sample(rows, replace: true)

  defp maybe_more_info(df, _df_source, facet_type, false), do: {df, facet_type, nil}

  defp maybe_more_info(df, df_source, facet_type, true) do
    {df, facet_type, DataFrame.join(df, df_source |> DataFrame.collect())}
  end
end
