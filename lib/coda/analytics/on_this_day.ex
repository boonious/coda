defmodule Coda.Analytics.OnThisDay do
  @moduledoc """
  Create on this day analytics for various facets
  """
  use Coda.Analytics.Base

  alias Explorer.DataFrame
  alias Explorer.Series

  require Explorer.DataFrame
  import Coda.Analytics.LastfmArchive.FacetConfigs, only: [facets: 0, facets_columns: 0]

  @facets facets()

  @impl true
  def dataframe(opts \\ []) do
    opts =
      Keyword.validate!(opts,
        format: :ipc_stream,
        facet: :scrobbles,
        columns: facets_columns()[:scrobbles],
        this_day: this_day(),
        user: LastfmArchive.default_user()
      )

    read_dataframe(opts) |> filter_dataframe(opts[:this_day], opts[:facet])
  end

  def new_facet_dataframes(opts \\ []) do
    for facet <- facets(), into: %{} do
      columns = facets_columns()[facet]
      df = dataframe(opts |> Keyword.put(:facet, facet) |> Keyword.put(:columns, columns))
      {facet, df}
    end
  end

  defp read_dataframe(opts), do: opts[:user] |> LastfmArchive.read(opts)

  defp filter_dataframe({:ok, df}, this_day, :scrobbles) do
    df |> DataFrame.filter(contains(mmdd, ^this_day))
  end

  defp filter_dataframe({:ok, df}, <<mm::binary-size(2), dd::binary>>, facet)
       when facet in @facets do
    df
    |> DataFrame.filter_with(fn facet ->
      facet["first_play"] |> Series.cast(:string) |> Series.contains("-#{mm}-#{dd}")
    end)
    |> DataFrame.arrange(desc: counts)
  end

  defp filter_dataframe(error, _this_day, _facet), do: error

  defp this_day(format \\ "%m%d"), do: Date.utc_today() |> Calendar.strftime(format)
end
