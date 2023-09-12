defmodule Coda.Behaviour.Analytics do
  @moduledoc """
  Behaviour of facets analytics
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

  @type facet_type :: DataFrame.column_name() | DataFrame.column_names()
  @type facets :: DataFrame.t()
  @type options :: Keyword.t()
  @type scrobbles :: DataFrame.t()

  @type facets_analytics_response :: {facets(), facet_type(), scrobbles()}

  @callback dataframe(options()) :: {:ok, dataframe()} | {:error, term}
  @callback digest(dataframe()) :: digest()

  for facet <- facets() do
    @callback unquote(:"top_#{facet}s")(dataframe(), options()) :: facets_analytics_response()
    @callback unquote(:"sample_#{facet}s")(dataframe(), options()) :: facets_analytics_response()
  end
end
