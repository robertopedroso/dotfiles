-------------------- HELPERS -------------------------------
local api, cmd, fn, g = vim.api, vim.cmd, vim.fn, vim.g
local opt, wo = vim.opt, vim.wo
local fmt = string.format

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  api.nvim_set_keymap(mode, lhs, rhs, options)
end


-------------------- GLOBAL KEYS ---------------------------
g.mapleader = ' '
g.maplocalleader = ' '

map('n', '<leader>w', ':w<CR>')
map('n', '<leader>q', ':q<CR>')
map('n', '<leader>e', ':e<CR>')

map('n', '<C-j>', '<C-W>j')
map('n', '<C-h>', '<C-W>h')
map('n', '<C-k>', '<C-W>k')
map('n', '<C-l>', '<C-W>l')

map('', '<leader>c', '"+y')       -- Copy to clipboard in normal, visual, select and operator modes


-------------------- OPTIONS -------------------------------
local indent, width = 4, 120
opt.autoread = true                 -- Don't bother me when a file changes
opt.clipboard = 'unnamedplus'       -- Allow copy/paste from system clipboard
opt.copyindent = true               -- Imitate adjacent indentation
opt.completeopt = {'menuone', 'noinsert', 'noselect'}  -- Completion options
opt.expandtab = true                -- Use spaces instead of tabs
opt.fillchars = { vert = ' ', stl = ' ', stlnc = ' ', fold = '-', diff = '┄' }
opt.hidden = true                   -- Enable background buffers
opt.ignorecase = true               -- Ignore case
opt.joinspaces = false              -- No double spaces with join
opt.list = true                     -- Show some invisible characters
opt.listchars = { tab = '» ', extends = '›', precedes = '‹', nbsp = '·', trail = '·' }
opt.number = true                   -- Show line numbers
opt.pastetoggle = '<F2>'            -- Paste mode
opt.pumheight = 12                  -- Max height of popup menu
opt.scrolloff = 4                   -- Lines of context
opt.shiftround = true               -- Round indent
opt.shiftwidth = indent             -- Size of an indent
opt.shortmess = 'atToOFc'           -- Prompt message options
opt.sidescrolloff = 8               -- Columns of context
opt.signcolumn = 'yes'              -- Show sign column
opt.smartcase = true                -- Do not ignore case with capitals
opt.smartindent = true              -- Insert indents automatically
opt.splitbelow = true               -- Put new windows below current
opt.splitright = true               -- Put new windows right of current
opt.tabstop = indent                -- Number of spaces tabs count for
opt.termguicolors = true            -- True color support
opt.textwidth = width               -- Maximum width of text
opt.updatetime = 100                -- Delay before swap file is saved
opt.wildmode = {'list', 'longest'}  -- Command-line completion mode
opt.wrap = false                    -- Disable line wrap

cmd 'colorscheme nord'
cmd 'filetype plugin indent on'


-------------------- PLUGINS -------------------------------
require('packer').startup(function()
    -- packer can manage itself
    use 'wbthomason/packer.nvim'

    -- theme & statusline
    use 'arcticicestudio/nord-vim'
    use 'kyazdani42/nvim-web-devicons'
    use 'glepnir/galaxyline.nvim'

    -- lsp/treesitter plugins
    use 'nvim-treesitter/nvim-treesitter'
    use 'kabouzeid/nvim-lspinstall'
    use 'neovim/nvim-lspconfig'
    use 'onsails/lspkind-nvim'
    use 'ray-x/lsp_signature.nvim'

    -- completion & snippets
    use 'hrsh7th/nvim-compe'
    use 'sbdchd/neoformat'

    -- file browsing & management
    use 'kyazdani42/nvim-tree.lua'
    use 'nvim-lua/plenary.nvim'
    use 'nvim-lua/popup.nvim'
    use 'nvim-telescope/telescope.nvim'
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use 'sudormrfbin/cheatsheet.nvim'

    -- git tools
    use { 'lewis6991/gitsigns.nvim', config = function() require('gitsigns').setup() end }
    use 'tpope/vim-fugitive'

    -- miscellaneous
    use { 'terrortylor/nvim-comment', config = function() require('nvim_comment').setup() end }
end)


-------------------- TREESITTER / LSP ----------------------
require('nvim-treesitter.configs').setup {
    ensure_installed = { 'bash', 'lua', 'python', 'javascript' },
    highlight = { enable = true, use_languagetree = true },
    indent = { enable = true },
}
require('lspkind').init()

local lspconfig = require('lspconfig')
local lspinstall = require('lspinstall')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    --Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    map('n', '<leader>,', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
    map('n', '<leader>;', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
    map('n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    map('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>')
    map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
    map('n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<CR>')
    map('n', '<leader>m', '<cmd>lua vim.lsp.buf.rename()<CR>')
    map('n', '<leader>r', '<cmd>lua vim.lsp.buf.references()<CR>')
    map('n', '<leader>s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
end


-- lspInstall + lspconfig stuff
local function setup_servers()
    lspinstall.setup()
    local servers = lspinstall.installed_servers()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    for _, lang in pairs(servers) do
        lspconfig[lang].setup {
            on_attach = on_attach,
            capabilities = capabilities,
            root_dir = vim.loop.cwd,
        }
    end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
lspinstall.post_install_hook = function()
   setup_servers() -- reload installed servers
   vim.cmd "bufdo e"
end

-- lsp_signature setup
require('lsp_signature').setup {
    bind = true,
    doc_lines = 2,
    floating_window = true,
    fix_pos = true,
    hint_enable = true,
    hint_prefix = " ",
    hint_scheme = "String",
    use_lspsaga = false,
    hi_parameter = "Search",
    max_height = 22,
    max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
    handler_opts = {
    border = "single", -- double, single, shadow, none
    },
    zindex = 200, -- by default it will be on top of all floating windows, set to 50 send it to bottom
    padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc
}


-------------------- COMPLETIONS ---------------------------
require('compe').setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = "enable",
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,
    source = {
        buffer = { kind = "﬘", true },
        luasnip = { kind = "﬌", true },
        nvim_lsp = true,
        nvim_lua = true,
    },
}


-------------------- TELESCOPE -----------------------------
require('telescope').setup {
   defaults = {
      vimgrep_arguments = {
         "rg",
         "--color=never",
         "--no-heading",
         "--with-filename",
         "--line-number",
         "--column",
         "--smart-case",
      },
      prompt_prefix = "   ",
      selection_caret = "  ",
      entry_prefix = "  ",
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = "descending",
      layout_strategy = "horizontal",
      layout_config = {
         horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
         },
         vertical = {
            mirror = false,
         },
         width = 0.87,
         height = 0.80,
         preview_cutoff = 120,
      },
      file_sorter = require("telescope.sorters").get_fuzzy_file,
      file_ignore_patterns = {},
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      path_display = { "absolute" },
      winblend = 0,
      border = {},
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      -- Developer configurations: Not meant for general override
      buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
   },
   extensions = {
      fzf = {
         fuzzy = true, -- false will only do exact matching
         override_generic_sorter = false, -- override the generic sorter
         override_file_sorter = true, -- override the file sorter
         case_mode = "smart_case", -- or "ignore_case" or "respect_case"
         -- the default case_mode is "smart_case"
      },
      media_files = {
         filetypes = { "png", "webp", "jpg", "jpeg" },
         find_cmd = "rg", -- find command (defaults to `fd`)
      },
   },
}

pcall(function()
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('media_files')
end)


-------------------- STATUSLINE ----------------------------


-------------------- MAPPINGS ------------------------------
map('n', '<leader>n', ':NvimTreeToggle<CR>')
map('n', '<leader>p', ':Telescope find_files<CR>')
map('n', '<leader>a', ':Telescope live_grep<CR>')
