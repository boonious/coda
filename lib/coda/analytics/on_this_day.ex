defmodule Coda.Analytics.OnThisDay do
  @moduledoc """
  Create on this day analytics for various facets
  """
  use Coda.Analytics.Base, facets: Coda.FacetSettings.facets()
  alias Explorer.DataFrame
  require Explorer.DataFrame

  def columns, do: ["id", "artist", "datetime", "year", "album", "track", "mmdd"]

  @impl true
  def dataframe(opts \\ []) do
    Keyword.validate!(opts, format: :ipc_stream, facet: :scrobbles, columns: columns())
    |> read_dataframe()
    |> filter_dataframe()
  end

  defp read_dataframe(opts) do
    LastfmArchive.default_user() |> LastfmArchive.read(opts)
  end

  defp filter_dataframe({:ok, df}), do: df |> DataFrame.filter(contains(mmdd, this_day()))
  defp filter_dataframe(error), do: error

  def this_day(format \\ "%m%d"), do: Date.utc_today() |> Calendar.strftime(format)
end
