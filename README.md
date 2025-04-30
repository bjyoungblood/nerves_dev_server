# Nerves Dev Server

Nerves Dev Server is part of the [Nerves Devtools] ecosystem. When installed on a
[Nerves] device, this package exposes a Phoenix application that provides runtime
data and an API for development utilities.

## Features

* Provide device metadata (e.g. firmware version, active partition, platform information, etc.)
* Hot module replacement

## Roadmap

* Improved API authentication
* Logging tools

## Installation

**Warning:** One of the main features of this application is the ability to do
remote code execution. You are advised against using this project in production
or on devices that may connect to untrusted networks. In the future, it will be
possible to enable/disable this functionality entirely, but we're not quite
there yet.

Add `nerves_dev_server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nerves_dev_server, "~> 0.1.0"}
  ]
end
```

## Configuration

To get started, add the following to your application's `config.exs`:

```elixir
config :nerves_dev_server,
  token_secret: "A RANDOM STRING",
  endpoint: [
    # See https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#module-runtime-configuration
    # for a full list of options.
    http: [ip: {0, 0, 0, 0}, port: 4000]
  ]

# Alternatively, you can use `Poison` or `JSON` here instead
config :phoenix, :json_library, Jason
```

[Nerves Devtools]: https://github.com/bjyoungblood/vscode-nerves-devtools
[Nerves]: https://nerves-project.org/
