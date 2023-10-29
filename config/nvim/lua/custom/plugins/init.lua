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
      local status_ok, which_key = pcall(require, 'which-key')
      if status_ok then
        which_key.register({
          ['<leader>t'] = { name = 'Res[t]', _ = 'which_key_ignore' }
        })
      end
      return {
        { '<leader>tr', '<Plug>RestNvim', desc = 'Run the request under cursor' },
        { '<leader>tp', '<Plug>RestNvimPreview', desc = 'Preview the curl command for the request under cursor' },
        { '<leader>tl', '<Plug>RestNvimLast', desc = 'Re-run the last request' }
      }
    end
  },
  'nvim-treesitter/nvim-treesitter-context',
  {
    'akinsho/toggleterm.nvim',
    opts = {
      size = vim.o.lines * 0.3,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = { },
      shade_terminals = true,
      shading_factor = 2,
      direction = 'horizontal',
      shell = vim.o.shell,
    },
    keys = function ()
      local status_ok, which_key = pcall(require, 'which_key')
      if status_ok then
        which_key.register({
          ['<leader>o'] = { name = 'To[g]gle terminal', _ = 'which_key_ignore' }
        })
      end
      vim.api.nvim_create_autocmd('TermOpen', {
        group = vim.api.nvim_create_augroup('kickstart-custom-term-open-mapping', { clear = true }),
        callback = function (args)
          local bufnr = args.buf
          local opts = { buffer = bufnr }
          vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
          vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
          vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
          vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
          vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
          vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
          vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
        end
      })
      return {
        { '<leader>oh', '<cmd>ToggleTerm direction=horizontal size=' .. tostring(vim.o.lines * 0.3) .. '<cr>', desc = 'Open terminal horizontally' },
        { '<leader>oc', '<cmd>ToggleTermSendCurrentLine<cr>', desc = 'Send current line under the cursor' },
        { '<leader>ov', '<cmd>ToggleTermSendVisualLines<cr>', desc = 'Send all lines visually selected' },
        { '<leader>os', '<cmd>ToggleTermSendVisualSelection<cr>', desc = 'Send visually selected text' }
      }
    end
  }
}
