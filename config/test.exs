import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :nerves_dev_server, NervesDevServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "gIKIG4SIVIJEXlHgVRQAi7XNwsFePoEWssNOXYboE1/XMVr7Zlh/ed/878pyUt9Z",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :nerves_motd, runtime_mod: NervesMOTD.MockRuntime
