defmodule Coda.FacetSettings do
  @moduledoc false

  def facets, do: [:album, :artist, :track]
  def default_opts(), do: [rows: 5, sort: :counts, filter: nil, counts: -1]
end
