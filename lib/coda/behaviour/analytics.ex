defmodule Coda.Behaviour.Analytics do
  @moduledoc """
  Behaviour, macro and functions for Explorer.DataFrame analytics
  """

  alias Explorer.DataFrame
  import Coda.FacetSettings

  @type dataframe :: DataFrame.t()
  @type digest :: %{
          album: %{count: integer()},
          artist: %{count: integer()},
          datetime: %{count: integer()},
          id: %{count: integer()},
          name: %{count: integer()},
          year: %{count: integer(), max: integer(), min: integer()}
        }

  @type group :: DataFrame.column_name() | DataFrame.column_names()
  @type options :: Keyword.t()

  @type top_facets :: DataFrame.t()
  @type top_facets_stats :: %{integer() => dataframe()}

  @type facets :: {top_facets(), top_facets_stats()}

  @callback dataframe(format: atom()) :: {:ok, dataframe()} | {:error, term}
  @callback digest(dataframe()) :: digest()

  for facet <- facets() do
    @callback unquote(:"top_#{facet}s")(dataframe(), options()) :: facets()
    @callback unquote(:"sample_#{facet}s")(dataframe(), options()) :: facets()
  end
end
