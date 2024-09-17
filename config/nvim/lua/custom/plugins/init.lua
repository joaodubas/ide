-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'joaodubas/gitlinker.nvim',
    config = function()
      local actions = require 'gitlinker.actions'
      local hosts = require 'gitlinker.hosts'
      require('gitlinker').setup {
        opts = {
          remote = 'origin',
          add_current_line_on_normal_mode = true,
          action_callback = actions.copy_to_clipboard,
          print_url = true,
        },
        callbacks = {
          ['github.com'] = hosts.get_github_type_url,
          ['bitbucket.org'] = hosts.get_bitbucket_type_url,
          ['gitea.dubas.dev'] = hosts.get_gitea_type_url,
        },
        mappings = '<leader>gy',
      }
    end,
  },
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    opts = {
      git_services = {
        ['gitea.dubas.dev'] = 'https://gitea.dubas.dev/${owner}/${repository}/compare/${branch_name}',
      },
    },
    keys = {
      { '<leader>gs', '<cmd>Neogit<cr>', desc = 'Git status' },
    },
  },
  'nvim-treesitter/nvim-treesitter-context',
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'BufRead',
    keys = function()
      local ufo = require 'ufo'
      return {
        { 'zR', ufo.openAllFolds, { desc = 'Open all folds' } },
        { 'zM', ufo.closeAllFolds, { desc = 'Close all folds' } },
        { 'zr', ufo.openFoldsExceptKinds, { desc = 'Open fold' } },
        { 'zm', ufo.closeFoldsWith, { desc = 'Close fold' } },
      }
    end,
    opts = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (' 󰁂 %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end

      return {
        fold_virt_text_handler = handler,
        provider_selector = function(_, _, _)
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
    },
    opts = {},
  },
  {
    'vhyrro/luarocks.nvim',
    priority = 1000,
    config = true,
  },
  {
    'EvWilson/slimux.nvim',
    lazy = true,
    opts = function()
      local status_ok, slimux = pcall(require, 'slimux')
      if not status_ok then
        return {}
      end
      return {
        target_socket = slimux.get_tmux_socket(),
        target_pane = string.format('%s.1', slimux.get_tmux_window()),
      }
    end,
    keys = function()
      local status_ok, which_key = pcall(require, 'which-key')
      if status_ok then
        which_key.add {
          { '<leader>m', group = 'Toggle ter[m]inal' },
        }
      end
      local slimux_status_ok, slimux = pcall(require, 'slimux')
      if not slimux_status_ok then
        return {}
      end
      return {
        {
          '<leader>xr',
          slimux.send_highlighted_text,
          mode = 'v',
          desc = 'Send currently highlighted text to configured tmux pane',
        },
        {
          '<leader>r',
          slimux.send_paragraph_text,
          mode = 'n',
          desc = 'Send paragraph under cursor to configured tmux pane',
        },
      }
    end,
  },
}
