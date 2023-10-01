-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'joaodubas/gitlinker.nvim',
    config = function ()
      local actions = require('gitlinker.actions')
      local hosts = require('gitlinker.hosts')
      require('gitlinker').setup({
        opts = {
          remote = "origin",
          add_current_line_on_normal_mode = true,
          action_callback = actions.copy_to_clipboard,
          print_url = true,
        },
        callbacks = {
          ["github.com"] = hosts.get_github_type_url,
          ["bitbucket.org"] = hosts.get_bitbucket_type_url,
          ["gitea.dubas.dev"] = hosts.get_gitea_type_url,
        },
        mappings = "<leader>gy"
      })
    end
  },
  {
    'rest-nvim/rest.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ft = {
      'http',
      'rest'
    },
    opts = {
      result_split_horizontal = false,
      result_split_in_place = false,
      skip_ssl_verification = false,
      encode_url = true,
      highlight = {
        enabled = true,
        timeout = 15
      },
      result = {
        show_url = true,
        show_curl_command = true,
        show_http_info = true,
        show_headers = true,
        formatters = {
          json = 'jq',
          html = false
        },
        jump_to_request = true,
        env_file = '.env',
        custom_dynamic_variables = { },
        yank_dry_run = true
      }
    },
    keys = function ()
      require('which-key').register({
        ['<leader>t'] = { name = 'Res[t]', _ = 'which_key_ignore' }
      })
      return {
        { '<leader>tr', '<Plug>RestNvim', desc = 'Run the request under cursor' },
        { '<leader>tp', '<Plug>RestNvimPreview', desc = 'Preview the curl command for the request under cursor' },
        { '<leader>tl', '<Plug>RestNvimLast', desc = 'Re-run the last request' }
      }
    end
  },
  {
    'Vigemus/iron.nvim',
    config = function ()
      local iron = require('iron.core')
      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            sh = {
              command = { 'fish' }
            },
            elixir = require('iron.fts.elixir').iex,
            javascript = require('iron.fts.javascript').node,
            python = require('iron.fts.python').ipython,
            typescript = require('iron.fts.typescript').ts
          }
        }
      })
    end
  }
}
