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

vim.o.wrap = false
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
-- open error diagnostic
vim.keymap.set('n', '<leader>d', ':lua vim.diagnostic.open_float(nil, {focus=false})<CR>')
-- apply fix if available
vim.keymap.set('n', '<leader>a', ':lua vim.lsp.buf.code_action()<CR>')

-- keymap to save vim session as default Session.vim and write quit all
vim.keymap.set('n', '<leader>sv', ':mksession! Session.vim | wqa! <CR>',
    { desc = 'save vim session then write and quit all force' })

vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>', { desc = 'Clear search highlighting' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- this function is custom and switches to the terminal loaded in buffer else opens a new
-- terminal in a split
function Open_or_switch_terminal()
    local terminal_buffer_found = false
    -- Iterate through all buffers
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        local buffer_name = vim.api.nvim_buf_get_name(buffer)
        -- Check if the buffer name starts with "term://"
        if (string.sub(buffer_name, 1, 7) == "term://") then
            -- Switch to the found terminal buffer
            vim.api.nvim_set_current_buf(buffer)
            terminal_buffer_found = true
            -- Enter Terminal mode automatically
            vim.cmd("startinsert")
            break
        end
    end
    -- If no terminal buffer was found, open a new one
    if not terminal_buffer_found then
        vim.cmd("terminal")
        -- Enter Terminal mode automatically
        vim.cmd("startinsert")
    end
end

vim.keymap.set('n', '<leader>t', '<cmd>lua Open_or_switch_terminal()<CR>',
    { desc = 'Switch to terminal or open new terminal if no terminal in buffer' })

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
                    "colorscheme nordfox")
            end
        },

        -- Completion Engine
        {
            'saghen/blink.cmp',
            opts = {
                keymap = { preset = 'default' },
                fuzzy = { implementation = 'lua', },
                sources = {
                    -- Here we tell the engine where to get suggestions from
                    default = { 'lsp', 'path', 'snippets', 'buffer' },
                },
            },
        },

        -- LSP
        -- !COMPLEX! Uses three different plugins working together here
        -- If you want to add LSP support for another language,
        -- 1. add the language server (example, "gopls") in the local servers lua table in the lspconfig setup
        -- 2. add the langaguge name  (example, "go") to the ensure_installed lua table in the treesitter setup
        -- 3. (optional) if you want specific linting rules install nvim-lint or conform.nvim and configure that
        {
            'neovim/nvim-lspconfig',
            dependencies = { 'saghen/blink.cmp', 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim' },
            config = function()
                -- the lspconfig is a collection of "blueprints" for how Neovim should
                -- talk to the different languages
                local lspconfig = require('lspconfig')

                -- lsp servers we want installed
                local servers = { 'lua_ls', 'pylsp', 'clangd', "herb_ls", "ts_ls", "jsonls", }

                -- gets the format for the blink completetion engine so we can use it
                -- to tell mason-lspconfig what format blink is expecting
                local capabilities = require('blink.cmp').get_lsp_capabilities()

                -- this tells Mason to download the servers and then tells the lspconfig
                -- to hook them into Neovim
                require('mason-lspconfig').setup({
                    ensure_installed = servers,
                    handlers = {
                        function(server_name)
                            lspconfig[server_name].setup({
                                capabilities = capabilities,
                            })
                        end,
                    },
                })
            end
        },

        {
            -- Treesitter is poplular because instead of just using simple RegEx to pattern
            -- match for colors, it actually parses code into a syntax tree
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                local status, configs = pcall(require, "nvim-treesitter.configs")
                if not status then
                    return
                end

                configs.setup({
                    ensure_installed = { "lua", "python", "markdown", "markdown_inline", "bash", "vim", "vimdoc", "c", "cpp", "json", },
                    highlight = { enabled = true },
                })
            end,
        },

        -- Markdown Rendering
        {
            "MeanderingProgrammer/render-markdown.nvim",
            dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
            -- passing opts = {} is shorthand for triggering the plugin's default settings
            opts = {},
        },


        -- External Binary Management with Mason
        -- Used for standalone setup for non-LSP tools if needed
        { "williamboman/mason.nvim", opts = {} },

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
