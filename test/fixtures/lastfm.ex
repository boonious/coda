defmodule Fixtures.Lastfm do
  @moduledoc false
  def recent_tracks_on_this_day(user, now \\ DateTime.utc_now() |> DateTime.to_unix()),
    do: recent_tracks(user, 1, now)

  def recent_tracks(user \\ "a_lastfm_user", count \\ 1, time \\ 1_618_327_602) do
    ~s"""
    {
      "recenttracks": {
        "track": [
          {
            "artist": {
              "mbid": "d3b2711f-2baa-441a-be95-14945ca7e6ea",
              "#text": "Roxette",
              "url": "https:\/\/www.last.fm\/music\/Roxette"
            },
            "album": {
              "mbid": "0c022aea-1ee8-4664-9287-4482fe345e18",
              "#text": "Fading Like a Flower (Every Time You Leave)"
            },
            "image": [
              {
                "size": "small",
                "#text": "https:\/\/lastfm.freetls.fastly.net\/i\/u\/34s\/bd70cbfa77064ce49672a60b55184a6b.jpg"
              },
              {
                "size": "medium",
                "#text": "https:\/\/lastfm.freetls.fastly.net\/i\/u\/64s\/bd70cbfa77064ce49672a60b55184a6b.jpg"
              },
              {
                "size": "large",
                "#text": "https:\/\/lastfm.freetls.fastly.net\/i\/u\/174s\/bd70cbfa77064ce49672a60b55184a6b.jpg"
              },
              {
                "size": "extralarge",
                "#text": "https:\/\/lastfm.freetls.fastly.net\/i\/u\/300x300\/bd70cbfa77064ce49672a60b55184a6b.jpg"
              }
            ],
            "streamable": "0",
            "date": {
              "uts": "#{time}",
              "#text": "13 Apr 2021, 15:26"
            },
            "url": "https:\/\/www.last.fm\/music\/Roxette\/_\/Physical+Fascination+(guitar+solo+version)",
            "name": "Physical Fascination (guitar solo version)",
            "mbid": "cd000775-0a7c-38ea-96ab-4dacfae789fe"
          }
        ],
        "@attr": {
          "user": "#{user}",
          "page": 1,
          "perPage": 1,
          "totalPages": 12,
          "total": #{count}
        }
      }
    }
    """
  end

  def recent_tracks_without_album_title(
        user \\ "a_lastfm_user",
        count \\ 1,
        time \\ 1_618_327_602
      ) do
    ~s"""
    {
      "recenttracks": {
        "track": [
          {
            "artist": {
              "mbid": "d3b2711f-2baa-441a-be95-14945ca7e6ea",
              "#text": "Roxette",
              "url": "https:\/\/www.last.fm\/music\/Roxette"
            },
            "album": {
              "mbid": "",
              "#text": ""
            },
            "image": [
              {
                "size": "small",
                "#text": "https:\/\/lastfm.freetls.fastly.net\/i\/u\/34s\/bd70cbfa77064ce49672a60b55184a6b.jpg"
              },
              {
                "size": "medium",
                "#text": "https:\/\/lastfm.freetls.fastly.net\/i\/u\/64s\/bd70cbfa77064ce49672a60b55184a6b.jpg"
              },
              {
                "size": "large",
                "#text": "https:\/\/lastfm.freetls.fastly.net\/i\/u\/174s\/bd70cbfa77064ce49672a60b55184a6b.jpg"
              },
              {
                "size": "extralarge",
                "#text": "https:\/\/lastfm.freetls.fastly.net\/i\/u\/300x300\/bd70cbfa77064ce49672a60b55184a6b.jpg"
              }
            ],
            "streamable": "0",
            "date": {
              "uts": "#{time}",
              "#text": "13 Apr 2021, 15:26"
            },
            "url": "https:\/\/www.last.fm\/music\/Roxette\/_\/Physical+Fascination+(guitar+solo+version)",
            "name": "Physical Fascination (guitar solo version)",
            "mbid": "cd000775-0a7c-38ea-96ab-4dacfae789fe"
          }
        ],
        "@attr": {
          "user": "#{user}",
          "page": 1,
          "perPage": 1,
          "totalPages": 12,
          "total": #{count}
        }
      }
    }
    """
  end
end
