defmodule Coda.Analytics.OnThisDayTest do
  use ExUnit.Case, async: true

  alias Explorer.DataFrame
  alias Coda.Analytics.OnThisDay
  alias LastfmArchive.DerivedArchiveMock

  import Coda.Factory
  import Hammox

  setup_all do
    user = LastfmArchive.default_user()
    today = Date.utc_today()

    first_time =
      DateTime.from_iso8601("#{today |> Date.add(-1) |> to_string()}T00:00:07Z")
      |> elem(1)
      |> DateTime.to_unix()

    latest =
      DateTime.from_iso8601("#{today |> Date.add(1) |> to_string()}T18:50:07Z")
      |> elem(1)
      |> DateTime.to_unix()

    file_archive_metadata =
      build(:file_archive_metadata,
        creator: user,
        first_scrobble_time: first_time,
        latest_scrobble_time: latest
      )

    %{
      user: user,
      dataframe: build(:scrobbles, rows: 1) |> dataframe(),
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
      dataframe: df,
      file_archive_metadata: metadata,
      options: opts
    } do
      DerivedArchiveMock
      |> expect(:describe, 2, fn ^user, options ->
        assert options |> Enum.into(%{}) == opts |> Enum.into(%{})
        {:ok, metadata}
      end)
      |> expect(:read, 2, fn ^metadata, _opts -> {:ok, df} end)

      assert %DataFrame{} = OnThisDay.dataframe()
      assert %DataFrame{} = df = OnThisDay.dataframe(opts)
      assert {1, _column_count} = df |> DataFrame.collect() |> DataFrame.shape()
    end

    test "return no data without scrobble on this day", %{
      user: user,
      file_archive_metadata: metadata,
      options: opts
    } do
      not_this_day = DateTime.utc_now() |> DateTime.add(-30, :day)
      not_this_day_df = build(:scrobbles, date_time: not_this_day) |> dataframe()

      DerivedArchiveMock
      |> expect(:describe, fn ^user, _pts -> {:ok, metadata} end)
      |> expect(:read, fn ^metadata, _opts ->
        {:ok, not_this_day_df}
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
