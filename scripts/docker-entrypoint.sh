#!/bin/bash
set -e

# NOTE: (jpd) setup elixir-ls for older versions of elixir
if [ ! -d ${LOCAL_SRC_HOME}/elixir-ls/release ]; then
	echo "setup elixir ls version 0.12.0"
	/usr/local/bin/elixir-ls-setup v0.12.0
	echo "setup elixir ls version 0.14.6"
	/usr/local/bin/elixir-ls-setup v0.14.6
fi

# NOTE: (jpd) create auto-completion
commands=(
	"ctlptl"
	"eksctl"
	"helm"
	"k3d"
	"k9s"
	"kind"
	"kubectl"
	"lefthook"
	"mise"
)
echo "create completion for ${commands[@]}"
for cmd in ${commands[@]}; do
	completion_dir=${XDG_CONFIG_HOME}/fish/completions/${cmd}.fish
	if [ ! -f ${completion_dir} ]; then
		echo "setup ${cmd} completion"
		$(echo ${cmd} completion fish) > ${completion_dir}
	fi
done

exec "$@"
