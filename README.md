# Nerves Dev Server

Nerves Dev Server is part of the [Nerves Devtools](https://github.com/bjyoungblood/vscode-nerves-devtools)
suite. When installed on a [Nerves](https://nerves-project.org/) device, this
package exposes a Phoenix application that provides runtime data and an API for
development utilities.

## Features

* Provide device metadata (e.g. firmware version, active partition, platform information, etc.)
* Hot module replacement

## Roadmap

* API authentication
* Logging tools

## Installation

**Warning:** One of the main features of this application is the ability to do
remote code execution. You are advised against using this project in production
or on devices that may connect to untrusted networks. In the future, it will be
possible to enable/disable this functionality entirely, but we're not quite
there yet.
