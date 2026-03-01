-- Bootstrap for lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    -- Try and clone the Lazy.nvim repository
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

-- [ GLOBAL SETTINGS ]
-- Setting leader and localleader before loading
-- lazy.nvim so that the mappings are correct
-- Also set vim.opt and vim.keymap settings here
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = 'yes'

vim.o.wrap = true
vim.o.breakindent = true
vim.o.linebreak = true
vim.o.showbreak = '↳'

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.inccommand = 'split'

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.cursorline = true

vim.o.scrolloff = 5

vim.o.confirm = true

vim.o.swapfile = false
vim.o.winborder = 'rounded'
vim.o.clipboard = 'unnamedplus'


-- [ KEYMAPS (for built in commands)]
-- Lazy doesn't allow config resourcing because it would load Lazy.nivm again
-- vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>i', ':e $MYVIMRC<CR>')

vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>')

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [ PLUGIN SPEC ]
require("lazy").setup({
    spec = {
        -- add plugins here

        -- Colorscheme
        {
            "EdenEast/nightfox.nvim",
            lazy = false,
            priority = 1000,
            config = function()
                vim.cmd(
                    "colorscheme duskfox")
            end
        },

        -- Completion Engine
        {
            'saghen/blink.cmp',
            opts = {
                keymap = { preset = 'default' },
                fuzzy = { implementation = 'lua', },
                sources = {
                    default = { 'lsp', 'path', 'snippets', 'buffer' },
                },
            },
        },

        -- LSP
        {
            'neovim/nvim-lspconfig',
            dependencies = { 'saghen/blink.cmp', 'williamboman/mason-lspconfig.nvim' },
            config = function()
                local servers = { 'lua_ls' }

                for _, server in ipairs(servers) do
                    local capabilities = require('blink.cmp').get_lsp_capabilities()

                    vim.lsp.config(server, {
                        capabilities = capabilities,
                    })
                    vim.lsp.enable(server)
                end
            end
        },

        -- External Binary Management
        { "williamboman/mason.nvim", opts = {} },
        {
            "williamboman/mason-lspconfig.nvim",
            opts = {
                -- Add language servers here and above in servers table
                ensure_installed = { "lua_ls" },
                automatic_installation = true,
            }
        },

        -- Utilities
        { "stevearc/oil.nvim",       opts = { view_options = { show_hidden = true } } },
        { "echasnovski/mini.pick",   version = false,                                 config = true },
        { 'windwp/nvim-autopairs',   event = "InsertEnter",                           config = true },
    },

    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "nightfox" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})

-- [ KEYMAPS (for plugin commands)]
vim.keymap.set('n', '<leader>e', ':Oil<CR>')
vim.keymap.set('n', '<leader>p', ':Pick files<CR>')
vim.keymap.set('n', '<leader>h', ':Pick help<CR>')
