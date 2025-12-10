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

-- ============================================================================
-- Plugin Setup
-- ============================================================================
require("lazy").setup({
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        light_style = "day",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "qf", "help" },
        day_brightness = 0.3,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  -- Formatting
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          markdown = { "prettier" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },
  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        typescript = { "eslint" },
        javascript = { "eslint" },
        typescriptreact = { "eslint" },
        javascriptreact = { "eslint" },
      }

      -- Auto lint on save
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "typescript",
          "tsx",
          "javascript",
          "json",
          "html",
          "css",
          "markdown",
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        matchup = {
          enable = true,
        },
      })
    end,
  },
  -- Matching Tag Highlighting
  {
    "andymass/vim-matchup",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.matchup_matchparen_enabled = 1
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_timeout = 300
      vim.g.matchup_matchparen_insert_timeout = 60
      vim.g.matchup_surround_enabled = 1
    end,
    config = function()
      -- Set custom highlight colors for matching tags
      local highlights = {
        MatchParen = { bg = "#3d59a1", fg = "#ffffff", bold = true, underline = true },
        MatchWord = { bg = "#3d59a1", fg = "#ffffff", bold = true, underline = true },
        MatchParenOffscreen = { bg = "#5a7bb1", fg = "#ffffff", bold = true },
      }
      for group, opts in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, opts)
      end
    end,
  },
  -- Markdown Rendering
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    config = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = "dark"
    end,
  },
  -- Markdown Rendering in Terminal 
  {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow"
  },
})

-- ============================================================================
-- Editor Settings
-- ============================================================================
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
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- ============================================================================
-- Autocommands
-- ============================================================================
-- Enable text wrapping for markdown and text files
local wrap_group = vim.api.nvim_create_augroup("WrapSettings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = wrap_group,
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- ============================================================================
-- Keymaps
-- ============================================================================
-- Map jj to escape (popular alternative for touch bar keyboards)
vim.keymap.set({ "i", "v", "c" }, "jj", "<Esc>", { noremap = true, silent = true })

-- Format buffer
vim.keymap.set({ "n", "v" }, "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

-- Diagnostic keymaps 
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {desc = 'Show diagnostic [E]rror message'})

-- Render Markdown in Browser
vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreview<cr>', {desc = '[M]arkdown [P]review'})
vim.keymap.set('n', '<leader>ms', '<cmd>MarkdownPreviewStop<cr>', {desc = '[M]arkdown [S]top'})

-- VSP Split Screen navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', {desc = "Move to left split"})
vim.keymap.set('n', '<C-j>', '<C-w>j', {desc = "Move to lower split"})
vim.keymap.set('n', '<C-k>', '<C-w>k', {desc = "Move to upper split"})
vim.keymap.set('n', '<C-l>', '<C-w>l', {desc = "Move to right split"})
