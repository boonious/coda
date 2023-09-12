defmodule Coda.Analytics.OnThisDayTest do
  use ExUnit.Case, async: true

  alias Explorer.DataFrame
  alias Coda.Analytics.OnThisDay
  alias LastfmArchive.DerivedArchiveMock

  import Fixtures.Archive
  import Fixtures.Lastfm
  import Hammox

  setup_all do
    user = LastfmArchive.default_user()
    today = Date.utc_today()

    file_archive_metadata =
      new_archive_metadata(
        user: user,
        start:
          DateTime.from_iso8601("#{today |> Date.add(-1) |> to_string()}T00:00:07Z")
          |> elem(1)
          |> DateTime.to_unix(),
        end:
          DateTime.from_iso8601("#{today |> Date.add(1) |> to_string()}T18:50:07Z")
          |> elem(1)
          |> DateTime.to_unix()
      )

    %{
      user: user,
      dataframe:
        user |> recent_tracks_on_this_day() |> dataframe() |> DataFrame.rename(name: "track"),
      file_archive_metadata: file_archive_metadata
    }
  end

  describe "dataframe/1" do
    setup context do
      this_day = Date.utc_today() |> Calendar.strftime("%m%d")

      %{
        options: [
          user: context.user,
          this_day: this_day,
          columns: OnThisDay.columns(),
          facet: :scrobbles,
          format: :ipc_stream
        ]
      }
    end

    test "contains data on this day", %{
      user: user,
      file_archive_metadata: metadata,
      options: opts
    } do
      single_scrobble_on_this_day = recent_tracks_on_this_day(user)

      DerivedArchiveMock
      |> expect(:describe, 2, fn ^user, options ->
        assert options |> Enum.into(%{}) == opts |> Enum.into(%{})
        {:ok, metadata}
      end)
      |> expect(:read, 2, fn ^metadata, _opts -> {:ok, dataframe(single_scrobble_on_this_day)} end)

      assert %DataFrame{} = OnThisDay.dataframe()
      assert %DataFrame{} = df = OnThisDay.dataframe(opts)
      assert {1, _column_count} = df |> DataFrame.collect() |> DataFrame.shape()
    end

    test "return no data without scrobble on this day", %{
      user: user,
      file_archive_metadata: metadata,
      options: opts
    } do
      not_now = DateTime.utc_now() |> DateTime.add(-5, :day) |> DateTime.to_unix()
      single_scrobble_not_on_this_day = recent_tracks_on_this_day(user, not_now)

      DerivedArchiveMock
      |> expect(:describe, fn ^user, _pts -> {:ok, metadata} end)
      |> expect(:read, fn ^metadata, _opts ->
        {:ok, dataframe(single_scrobble_not_on_this_day)}
      end)

      assert %DataFrame{} =
               df = OnThisDay.dataframe(format: opts[:format], this_day: opts[:this_day])

      assert {0, _column_count} = df |> DataFrame.collect() |> DataFrame.shape()
    end

    test "handles archive read error", %{
      user: user,
      file_archive_metadata: metadata,
      options: opts
    } do
      DerivedArchiveMock
      |> expect(:describe, fn ^user, ^opts -> {:ok, metadata} end)
      |> expect(:read, fn ^metadata, ^opts -> {:error, :einval} end)

      assert {:error, :einval} = OnThisDay.dataframe(format: opts[:format])
    end
  end

  test "digest/0", %{dataframe: df} do
    assert %{
             album: %{count: 1},
             artist: %{count: 1},
             datetime: %{count: 1},
             id: %{count: 1},
             track: %{count: 1},
             year: %{count: 1, max: 2023, min: 2023}
           } = df |> OnThisDay.digest()
  end
end
