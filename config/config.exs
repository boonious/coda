import Config

# Lastfm user for the archive
config :lastfm_archive,
  data_dir: "./lastfm_data/",
  user: ""

config :logger, level: :info

import_config("#{config_env()}.exs")

# provides the above (private) credentails for local dev/testing purposes in lastfm.secret.exs
if File.exists?("./config/lastfm.secret.exs"), do: import_config("lastfm.secret.exs")
