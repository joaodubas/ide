#!/usr/bin/env bash
set -e

function setup() {
	local elixir_ls_home=${LOCAL_SRC_HOME}/elixir-ls
	local elixir_ls_release=${elixir_ls_home}/release
	echo "elixir-ls repo"
	cd ${elixir_ls_home}
	echo "checkout versions ${1}"
	git checkout tags/${1}
	echo "set erlang/elixir versions"
	cp .release-tool-versions .tool-versions
	local current_erlang=$(mise current erlang)
	local current_elixir=$(mise current elixir)
	echo "using erlang ${current_erlang} / elixir ${current_elixir}"
	echo "install erlang/elixir runtimes"
	KERL_CONFIGURE_OPTIONS="-with-ssl=${HOME}/.local/lib/ssl" mise install
	echo "install elixir-ls deps"
	mise exec erlang@${current_erlang} elixir@${current_elixir} --command "mix do local.rebar --force, local.hex --force, deps.get, deps.compile"
	echo "compile and release elixir-ls"
	mise exec erlang@${current_erlang} elixir@${current_elixir} --command "MIX_ENV=prod mix compile"
	mise exec erlang@${current_erlang} elixir@${current_elixir} --command "MIX_ENV=prod mix elixir_ls.release -o ${elixir_ls_release}/${1}"
	echo "remove local .tool-versions"
	cp .tool-versions ${elixir_ls_release}/${1}
	rm .tool-versions
	mise exec erlang@${current_erlang} elixir@${current_elixir} --command "mix do deps.clean --all, clean"
	git checkout master
}

setup $1
