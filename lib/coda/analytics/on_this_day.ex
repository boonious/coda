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
    opts =
      Keyword.validate!(opts,
        format: :ipc_stream,
        facet: :scrobbles,
        columns: columns(),
        this_day: this_day(),
        user: LastfmArchive.default_user()
      )

    read_dataframe(opts) |> filter_dataframe(opts[:this_day])
  end

  defp read_dataframe(opts), do: opts[:user] |> LastfmArchive.read(opts)

  defp filter_dataframe({:ok, df}, this_day) do
    df |> DataFrame.filter(contains(mmdd, ^this_day))
  end

  defp filter_dataframe(error, _this_day), do: error

  defp this_day(format \\ "%m%d"), do: Date.utc_today() |> Calendar.strftime(format)
end
