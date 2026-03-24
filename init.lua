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
  -- Commenting
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("Comment").setup()
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
  -- Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
    end,
  },

  -- ============================================================================
  -- LSP + Completion (Intellisense)
  -- ============================================================================

  -- Mason: Easy LSP server installation
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason-LSPConfig: Bridge between Mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",        -- TypeScript/JavaScript
          "lua_ls",          -- Lua
          "cssls",           -- CSS
          "html",            -- HTML
          "jsonls",          -- JSON
          "tailwindcss",     -- Tailwind CSS
        },
      })
    end,
  },

  -- LSP Config (Neovim 0.11+ API)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure LSP servers using new vim.lsp.config API
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.config("cssls", { capabilities = capabilities })
      vim.lsp.config("html", { capabilities = capabilities })
      vim.lsp.config("jsonls", { capabilities = capabilities })
      vim.lsp.config("tailwindcss", { capabilities = capabilities })

      -- Enable the servers
      vim.lsp.enable({ "ts_ls", "lua_ls", "cssls", "html", "jsonls", "tailwindcss" })

      -- LSP Keymaps (set when LSP attaches to buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

  -- Completion Engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP completions
      "hrsh7th/cmp-buffer",       -- Buffer words
      "hrsh7th/cmp-path",         -- File paths
      "L3MON4D3/LuaSnip",         -- Snippet engine (required)
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- NON-AGGRESSIVE: Only show completions when you ask for them
        completion = {
          autocomplete = false, -- Disable auto-popup
        },

        mapping = cmp.mapping.preset.insert({
          -- Ctrl+Space to trigger completions manually
          ["<C-Space>"] = cmp.mapping.complete(),

          -- Navigate completion menu
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),

          -- Scroll docs
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Confirm selection
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping.confirm({ select = true }),

          -- Cancel
          ["<C-e>"] = cmp.mapping.abort(),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),

        -- Simple formatting
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              buffer = "[Buf]",
              path = "[Path]",
              luasnip = "[Snip]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })
    end,
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

-- Force 2-space indentation for web dev files
local indent_group = vim.api.nvim_create_augroup("IndentSettings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = indent_group,
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "json", "html", "css", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
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
