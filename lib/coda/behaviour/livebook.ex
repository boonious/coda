defmodule Coda.Behaviour.Livebook do
  @moduledoc """
  Behaviour of analytics Livebook.
  """

  @type digest :: Coda.Behaviour.Analytics.digest()
  @type facets :: Coda.Behaviour.Analytics.facets()
  @type kino_ui :: Kino.Markdown.t() | struct()
  @type options :: keyword()

  @callback overview(digest()) :: kino_ui()
  @callback render_facets(facets(), options) :: kino_ui()
end
