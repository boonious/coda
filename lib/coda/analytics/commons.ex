defmodule Coda.Analytics.Commons do
  @moduledoc """
  Common data frame analytics functions.
  """
  alias Explorer.DataFrame
  require Explorer.DataFrame
  import Coda.Analytics.LastfmArchive.FacetConfigs

  @type dataframe :: Coda.Behaviour.Analytics.dataframe()
  @type facet_type :: Coda.Behaviour.Analytics.facet_type()

  @doc """
  Compute count and frequency for a columns subset.

  Options:
  - `filter` - an `Explorer.DataFrame` filter function that excludes data in analytics
  - `counts` - includes only facets with this counts (integer)
  - `sort` - by `:counts` or `:freq` (frequencies over the years)
  """
  @spec frequencies(dataframe(), facet_type(), keyword()) :: dataframe()
  def frequencies(df, facet_type, opts \\ [])
  def frequencies(df, facet_type, []), do: df |> DataFrame.frequencies(facet_type |> List.wrap())

  def frequencies(df, facet_type, opts) when is_list(opts) do
    opts = Keyword.validate!(opts, default_opts())

    df
    |> maybe_pre_filter(opts[:filter])
    |> compute_counts_and_freq(facet_type |> List.wrap(), opts[:sort])
    |> maybe_post_filter_by_count(opts[:counts])
  end

  defp compute_counts_and_freq(df, facet_type, :counts) do
    df |> DataFrame.frequencies(facet_type)
  end

  defp compute_counts_and_freq(df, facet_type, :freq) do
    df
    |> DataFrame.distinct(facet_type ++ ["year"])
    |> DataFrame.frequencies(facet_type)
    |> DataFrame.rename(counts: "freq")
    |> DataFrame.join(df |> DataFrame.frequencies(facet_type))
  end

  defp maybe_pre_filter(df, nil), do: df
  defp maybe_pre_filter(df, filter), do: df |> DataFrame.filter_with(filter)

  defp maybe_post_filter_by_count(df, -1), do: df
  defp maybe_post_filter_by_count(df, counts), do: df |> DataFrame.filter(counts == ^counts)

  @doc """
  Rank data frame by counts or (year) frequency, limits to nth rows.
  """
  @spec rank_and_limit(dataframe(), keyword()) :: dataframe()
  def rank_and_limit(df, opts \\ []) do
    opts = Keyword.validate!(opts, default_opts())

    df
    |> DataFrame.arrange_with(&[desc: &1[opts[:sort]]])
    |> DataFrame.head(opts[:rows])
  end
end
