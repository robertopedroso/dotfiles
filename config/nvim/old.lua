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


-------------------- PLUGINS -------------------------------
cmd 'packadd paq-nvim'
local paq = require('paq-nvim').paq

paq {'savq/paq-nvim', opt = true}
paq {'arcticicestudio/nord-vim'}

paq {'a-vrma/black-nvim'}
paq {'airblade/vim-rooter'}
paq {'hrsh7th/nvim-compe'}
paq {'junegunn/fzf'}
paq {'junegunn/fzf.vim'}
paq {'justinmk/vim-dirvish'}
paq {'kyazdani42/nvim-web-devicons'}
paq {'kyazdani42/nvim-tree.lua'}
paq {'lervag/vimtex'}
paq {'lewis6991/gitsigns.nvim'}
paq {'machakann/vim-sandwich'}
paq {'neovim/nvim-lspconfig'}
paq {'nvim-lua/plenary.nvim'}
paq {'nvim-treesitter/nvim-treesitter'}
paq {'nvim-treesitter/nvim-treesitter-textobjects'}
paq {'ojroques/nvim-bufbar'}
paq {'ojroques/nvim-bufdel'}
paq {'ojroques/nvim-hardline'}
paq {'ojroques/nvim-lspfuzzy'}
paq {'ojroques/vim-oscyank'}
paq {'savq/paq-nvim', opt = true}
paq {'terrortylor/nvim-comment'}
paq {'tpope/vim-fugitive'}
paq {'tpope/vim-unimpaired'}


-------------------- PLUGIN SETUP --------------------------
-- comment
require('nvim_comment').setup {}

-- compe
require('compe').setup {
  min_length = 2,
  preselect = 'disable',
  max_abbr_width = 80, max_kind_width = 40, max_menu_width = 40,
  source = {buffer = true, path = true, nvim_lsp = true, omni = {filetypes = {'tex'}}},
}

-- dirvish
g['dirvish_mode'] = [[:sort ,^.*[\/],]]

-- fugitive and git
local log = [[\%C(yellow)\%h\%Cred\%d \%Creset\%s \%Cgreen(\%ar) \%Cblue\%an\%Creset]]
map('n', '<leader>g<space>', ':Git ')
map('n', '<leader>gd', '<cmd>Gvdiffsplit<CR>')
map('n', '<leader>gg', '<cmd>Git<CR>')
map('n', '<leader>gl', fmt('<cmd>term git log --graph --all --format="%s"<CR><cmd>start<CR>', log))

-- fzf
g['fzf_action'] = {['ctrl-s'] = 'split', ['ctrl-v'] = 'vsplit'}
map('n', '<leader>/', '<cmd>BLines<CR>')
map('n', '<leader>p', '<cmd>Files<CR>')
map('n', '<leader>r', '<cmd>Rg<CR>')
map('n', 's', '<cmd>Buffers<CR>')

-- gitsigns
require('gitsigns').setup {
  signs = {
    add = {text = '+'},
    change = {text = '~'},
    delete = {text = '-'}, topdelete = {text = '-'}, changedelete = {text = '≃'},
  },
}

-- hardline
require('hardline').setup {
  bufferline = false,
  theme = 'nord',
  sections = {
    {class = 'mode', item = require('hardline.parts.mode').get_item},
    {class = 'high', item = require('hardline.parts.git').get_item, hide = 80},
    {class = 'med', item = require('hardline.parts.filename').get_item},
    {class = 'med', item ='%='},
    {class = 'low', item = require('hardline.parts.wordcount').get_item, hide = 80},
    {class = 'error', item = require('hardline.parts.lsp').get_error},
    {class = 'warning', item = require('hardline.parts.lsp').get_warning},
    {class = 'warning', item = require('hardline.parts.whitespace').get_item},
    {class = 'high', item = require('hardline.parts.filetype').get_item, hide = 80},
    {class = 'mode', item = require('hardline.parts.line').get_item},
  }
}

-- lspfuzzy
require('lspfuzzy').setup {}

-- vim-sandwich
cmd 'runtime macros/sandwich/keymap/surround.vim'

-- vimtex
g['vimtex_quickfix_mode'] = false

-- black
map('n', '<leader>b', '<cmd>call Black()<cr>')

-- nvim-tree
g.nvim_tree_side = 'left'
map('n', '<leader>n', ':NvimTreeToggle<CR>')
map('n', '<leader>r', ':NvimTreeRefresh<CR>')
map('n', '<leader>f', ':NvimTreeFindFile<CR>')


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


-------------------- MAPPINGS ------------------------------
map('n', '<leader>w', ':w<CR>')
map('n', '<leader>q', ':q<CR>')
map('n', '<leader>e', ':e<CR>')

map('n', '<C-j>', '<C-W>j')
map('n', '<C-h>', '<C-W>h')
map('n', '<C-k>', '<C-W>k')
map('n', '<C-l>', '<C-W>l')

map('', '<leader>c', '"+y')       -- Copy to clipboard in normal, visual, select and operator modes



-------------------- TREE SITTER ---------------------------
require('nvim-treesitter.configs').setup {
  ensure_installed = 'maintained',
  highlight = {enable = true},
  indent = {enable = true},
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ['aa'] = '@parameter.outer', ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer', ['if'] = '@function.inner',
        ['ac'] = '@class.outer', ['ic'] = '@class.inner',
      },
    },
    swap = {
      enable = true,
      swap_next = {['<leader>a'] = '@parameter.inner'},
      swap_previous = {['<leader>A'] = '@parameter.inner'},
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {[']a'] = '@parameter.outer', [']f'] = '@function.outer', [']c'] = '@class.outer'},
      goto_next_end = {[']A'] = '@parameter.outer', [']F'] = '@function.outer', [']C'] = '@class.outer'},
      goto_previous_start = {['[a'] = '@parameter.outer', ['[f'] = '@function.outer', ['[c'] = '@class.outer'},
      goto_previous_end = {['[A'] = '@parameter.outer', ['[F'] = '@function.outer', ['[C'] = '@class.outer'},
    },
  },
}


-------------------- LANGUAGE SERVER -----------------------
local lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on the below functions
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

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "pyright" }
for _, lsp_name in ipairs(servers) do
  lsp[lsp_name].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end


require('compe').setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    nvim_lsp = true;
  };
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
