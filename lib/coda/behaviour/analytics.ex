defmodule Coda.Behaviour.Analytics do
  @moduledoc """
  Behaviour of facets analytics
  """

  alias Explorer.DataFrame
  import Coda.Analytics.LastfmArchive.FacetConfigs

  @type dataframe :: DataFrame.t()
  @type digest :: %{
          counts: integer(),
          max_year: integer(),
          min_year: integer(),
          n_albums: integer(),
          n_artists: integer(),
          n_tracks: integer(),
          n_years: integer(),
          years_digest: list(year_count())
        }

  @type year_count :: %{year: integer(), counts: integer()}
  @type facet_type :: DataFrame.column_name() | DataFrame.column_names()
  @type facets :: DataFrame.t()
  @type options :: Keyword.t()
  @type scrobbles :: DataFrame.t()

  @type facets_analytics_response :: {facets(), facet_type(), scrobbles()}

  @callback dataframe(options()) :: {:ok, dataframe()} | {:error, term}
  @callback digest(dataframe()) :: digest()

  for facet <- facets() do
    @callback unquote(:"top_#{facet}")(dataframe(), options()) :: facets_analytics_response()
    @callback unquote(:"sample_#{facet}")(dataframe(), options()) :: facets_analytics_response()
  end
end
