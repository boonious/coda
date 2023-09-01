import Config

config :lastfm_archive,
  data_dir: "./lastfm_data/test/",
  interval: 1,
  lastfm_api_key: "",
  per_page: 200,
  user: "test_user",
  derived_archive: LastfmArchive.DerivedArchiveMock

config :logger,
  level: :info
