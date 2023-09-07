defmodule Fixtures.Archive do
  @moduledoc false
  alias LastfmArchive.Archive.Metadata

  @registered_time DateTime.from_iso8601("2021-04-01T18:50:07Z") |> elem(1) |> DateTime.to_unix()
  @latest_scrobble_time DateTime.from_iso8601("2021-04-03T18:50:07Z")
                        |> elem(1)
                        |> DateTime.to_unix()
  @date ~D[2021-04-03]
  @total 400

  @spec new_archive_metadata(keyword) :: LastfmArchive.Archive.Metadata.t()
  def new_archive_metadata(args) when is_list(args) do
    args =
      Keyword.validate!(args,
        user: "a_lastfm_user",
        start: @registered_time,
        end: @latest_scrobble_time,
        date: @date,
        type: :scrobbles,
        total: @total
      )

    %{
      Metadata.new(Keyword.get(args, :user))
      | temporal: {Keyword.get(args, :start), Keyword.get(args, :end)},
        extent: Keyword.get(args, :total),
        date: Keyword.get(args, :date),
        type: Keyword.get(args, :type)
    }
  end

  def dataframe(data \\ scrobbles_json()) do
    data
    |> Jason.decode!()
    |> LastfmArchive.Archive.Scrobble.new()
    |> Enum.map(&Map.from_struct/1)
    |> Explorer.DataFrame.new(lazy: true)
  end

  def scrobbles_json(), do: gzipped_scrobbles() |> :zlib.gunzip()
  def gzipped_scrobbles(), do: File.read!("test/fixtures/200_001.gz")
end
