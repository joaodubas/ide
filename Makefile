root_dir := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
neovim_patch_file := $(root_dir)/patch/kickstart.nvim/updates.patch
neovim_config_dir := $(XDG_CONFIG_HOME)/nvim

.DEFAULT_GOAL = help

.PHONY: apply_patch_init_lua
apply_patch_init_lua: ## apply the patch file in kickstart's init.lua file
	@cd $(neovim_config_dir) && git apply $(neovim_patch_file)

.PHONY: patch_init_lua
patch_init_lua: ## create a patch file with the changes made in kickstart's init.lua file
	@cd $(neovim_config_dir) && git diff --patch init.lua > $(neovim_patch_file)

.PHONY: patch_init_lua_dry_run
patch_init_lua_dry_run: ## show the changes made in kickstart's init.lua file
	@cd $(neovim_config_dir) && git --patch init.lua

.PHONY: help
help: ## show help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
