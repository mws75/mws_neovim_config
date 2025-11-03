-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic Neovim settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Plugin setup
require("lazy").setup({
  -- Tokyo Night colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
        light_style = "day",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "qf", "help" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = false,
        lualine_bold = false,
        on_colors = function(colors) end,
        on_highlights = function(highlights, colors) end,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = {"stylua"},
          javascript = {"prettier"},
          typescript = {"prettier"},
          javascriptreact = {"prettier"},
          typescriptreact = {"prettier"},
          json = {"prettier"},
          css = {"prettier"},
          html = {"prettier"},
          markdown = {"prettier"},
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = {"BufReadPre", "BufNewFile"},
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        typescript = {"eslint"},
        javascript = {"eslint"},
        typescriptreact = {"eslint"},
        javascriptreact = {"eslint"},
      }
     -- Auto lint on save
     local lint_augroup = vim.api.nvim_create_augroup("lint", {clear = true})

     vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost", "InsertLeave"}, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
     })
   end,
  },
  {
    "andymass/vim-matchup",
    event = "VimEnter",
    config = function()
      -- Enable matchup integration with % motion
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      -- Optional: Enable highlighting delay (reduces lag)
      vim.g.matchup_matchparen_deferred = 1
      -- Optional: Highlight timeout in milliseconds
      vim.g.matchup_matchparen_timeout = 300
      vim.g.matchup_matchparen_insert_timeout = 60
    end,
  },
})

-- Basic editor settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50

-- Use System Clipboard by default
vim.opt.clipboard = "unnamedplus"

-- Key Mappings 
-- Map jj to escape (popular alternative for touch bar keyboards)
vim.keymap.set({'i', 'v', 'c'}, 'jj', '<Esc>', {
  noremap = true, silent = true}) 

vim.keymap.set({'n', 'v'}, '<leader>f', function()
  require("conform").format({async = true, lsp_fallback = true })
end, {desc = "Format buffer" }) 



