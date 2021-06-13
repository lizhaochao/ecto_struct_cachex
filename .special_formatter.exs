[
  line_length: 120,
  inputs: [
    "{mix,.formatter}.exs",
    "{bench,config,test}/**/*.{ex,exs}",
    "lib/application.ex",
    "lib/config.ex",
    "lib/core.ex",
    "lib/ecto_struct_cached.ex",
    "lib/error.ex",
    "lib/list.ex",
    "lib/lru.ex",
    "lib/repo/**/*.ex",
    "lib/decorator/**/*.ex"
  ],
  subdirectories: ["lib/cache.ex"]
]
