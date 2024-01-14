#!/bin/bash
set -e

# NOTE (jpd): setup elixir-ls for older versions of elixir
if [ ! -d ${LOCAL_SRC_HOME}/elixir-ls/release ]; then
	echo "setup elixir ls version 0.12.0"
	/usr/local/bin/elixir-ls-setup v0.12.0
	echo "setup elixir ls version 0.14.6"
	/usr/local/bin/elixir-ls-setup v0.14.6
fi

exec "$@"
