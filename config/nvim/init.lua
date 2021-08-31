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
opt.showmode = false                -- We use the statusline for this instead
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
    use 'jose-elias-alvarez/null-ls.nvim'

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
    use { 'folke/zen-mode.nvim', config = function() require('zen-mode').setup() end }
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
local null_ls = require('null-ls')

null_ls.config({
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.stylua
    }
})

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) api.nvim_buf_set_option(bufnr, ...) end

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

    -- autoformat
    if client.resolved_capabilities.document_formatting then
        cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end
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

    lspconfig['null-ls'].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = vim.loop.cwd,
    })
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
lspinstall.post_install_hook = function()
   setup_servers() -- reload installed servers
   cmd "bufdo e"
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
local gl = require('galaxyline')
local gls = gl.section
local condition = require('galaxyline.condition')

local statusline_style = {
    left = " ",
    right = " ",
    main_icon = "  ",
    vi_mode_icon = " ",
    position_icon = " ",
}

local left_separator = statusline_style.left
local right_separator = statusline_style.right

local colors = {
    white = "#abb2bf",
    darker_black = "#2a303c",
    black = "#2E3440", --  nvim bg
    black2 = "#343a46",
    one_bg = "#373d49",
    one_bg2 = "#464c58",
    one_bg3 = "#494f5b",
    grey = "#4b515d",
    grey_fg = "#565c68",
    grey_fg2 = "#606672",
    light_grey = "#646a76",
    red = "#BF616A",
    baby_pink = "#de878f",
    pink = "#d57780",
    line = "#3a404c", -- for lines like vertsplit
    green = "#A3BE8C",
    vibrant_green = "#afca98",
    blue = "#7797b7",
    nord_blue = "#81A1C1",
    yellow = "#EBCB8B",
    sun = "#e1c181",
    purple = "#aab1be",
    dark_purple = "#B48EAD",
    teal = "#6484a4",
    orange = "#e39a83",
    cyan = "#9aafe6",
    statusline_bg = "#333945",
    lightbg = "#3f4551",
    lightbg2 = "#393f4b",
    pmenu_bg = "#A3BE8C",
    folder_bg = "#7797b7",
}

local mode_colors = {
    [110] = { "NORMAL", colors.red },
    [105] = { "INSERT", colors.dark_purple },
    [99] = { "COMMAND", colors.pink },
    [116] = { "TERMINAL", colors.green },
    [118] = { "VISUAL", colors.cyan },
    [22] = { "V-BLOCK", colors.cyan },
    [86] = { "V_LINE", colors.cyan },
    [82] = { "REPLACE", colors.orange },
    [115] = { "SELECT", colors.nord_blue },
    [83] = { "S-LINE", colors.nord_blue },
}

local mode = function(n)
    return mode_colors[vim.fn.mode():byte()][n]
end

local checkwidth = function()
   local squeeze_width = vim.fn.winwidth(0) / 2
   if squeeze_width > 30 then
      return true
   end
   return false
end

gl.short_line_list = { " " }

gls.left[1] = {
   FirstElement = {
      provider = function()
         return "▋"
      end,
      highlight = { colors.nord_blue, colors.nord_blue },
   },
}

gls.left[2] = {
   statusIcon = {
      provider = function()
         return statusline_style.main_icon
      end,
      highlight = { colors.statusline_bg, colors.nord_blue },
      separator = right_separator,
      separator_highlight = { colors.nord_blue, colors.one_bg2 },
   },
}

gls.left[3] = {
   left_arow2 = {
      provider = function() end,
      separator = right_separator .. " ",
      separator_highlight = { colors.one_bg2, colors.lightbg },
   },
}

gls.left[4] = {
   FileIcon = {
      provider = "FileIcon",
      condition = condition.buffer_not_empty,
      highlight = { colors.white, colors.lightbg },
   },
}

gls.left[5] = {
   FileName = {
      provider = function()
         local fileinfo = require "galaxyline.provider_fileinfo"

         if vim.api.nvim_buf_get_name(0):len() == 0 then
            return ""
         end

         return fileinfo.get_current_file_name("", "")
      end,
      highlight = { colors.white, colors.lightbg },
      separator = right_separator,
      separator_highlight = { colors.lightbg, colors.lightbg2 },
   },
}

gls.left[6] = {
   current_dir = {
      provider = function()
         local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
         return "  " .. dir_name .. " "
      end,
      highlight = { colors.grey_fg2, colors.lightbg2 },
      separator = right_separator,
      separator_highlight = { colors.lightbg2, colors.statusline_bg },
   },
}

gls.left[7] = {
   DiffAdd = {
      provider = "DiffAdd",
      condition = checkwidth,
      icon = "  ",
      highlight = { colors.white, colors.statusline_bg },
   },
}

gls.left[8] = {
   DiffModified = {
      provider = "DiffModified",
      condition = checkwidth,
      icon = "   ",
      highlight = { colors.grey_fg2, colors.statusline_bg },
   },
}

gls.left[9] = {
   DiffRemove = {
      provider = "DiffRemove",
      condition = checkwidth,
      icon = "  ",
      highlight = { colors.grey_fg2, colors.statusline_bg },
   },
}

gls.left[10] = {
   DiagnosticError = {
      provider = "DiagnosticError",
      icon = "  ",
      highlight = { colors.red, colors.statusline_bg },
   },
}

gls.left[11] = {
   DiagnosticWarn = {
      provider = "DiagnosticWarn",
      icon = "  ",
      highlight = { colors.yellow, colors.statusline_bg },
   },
}

gls.right[1] = {
   lsp_status = {
      provider = function()
         local clients = vim.lsp.get_active_clients()
         if next(clients) ~= nil then
            local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
            for _, client in ipairs(clients) do
               local filetypes = client.config.filetypes
               if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                  return " " .. "  " .. " LSP"
               end
            end
            return ""
         else
            return ""
         end
      end,
      highlight = { colors.grey_fg2, colors.statusline_bg },
   },
}

gls.right[2] = {
   GitIcon = {
      provider = function()
         return "  "
      end,
      condition = require("galaxyline.condition").check_git_workspace,
      highlight = { colors.grey_fg2, colors.statusline_bg },
      separator = " ",
      separator_highlight = { colors.statusline_bg, colors.statusline_bg },
   },
}

gls.right[3] = {
   GitBranch = {
      provider = "GitBranch",
      condition = require("galaxyline.condition").check_git_workspace,
      highlight = { colors.grey_fg2, colors.statusline_bg },
   },
}
gls.right[4] = {
    space = {
        provider = function() return " " end,
        highlight = { colors.grey_fg2, colors.statusline_bg },
    }
}

gls.right[5] = {
   ViMode = {
      provider = function()
         vim.cmd("hi GalaxyViMode guifg=" .. mode(2))
         return " " .. mode(1) .. " "
      end,
      highlight = { "GalaxyViMode", colors.lightbg2 },
      separator = right_separator,
      separator_highlight = { colors.statusline_bg, colors.lightbg2 },
   },
}

gls.right[6] = {
   line_percentage = {
      provider = function()
        local current_line = vim.fn.line "."
        local total_line = vim.fn.line "$"

        if current_line == 1 then
            return " Top  "
        elseif current_line == vim.fn.line "$" then
            return " Bot  "
        end

        local result, _ = math.modf((current_line / total_line) * 100)
        if result < 10 then
            return "  " .. result .. "%  "
        else
            return " " .. result .. "%  "
        end
      end,
      highlight = { colors.green, colors.lightbg },
      separator = right_separator,
      separator_highlight = { colors.lightbg2, colors.lightbg },
   },
}

-------------------- MAPPINGS ------------------------------
map('n', '<leader>n', ':NvimTreeToggle<CR>')
map('n', '<leader>p', ':Telescope find_files<CR>')
map('n', '<leader>g', ':Telescope live_grep<CR>')
map('n', '<leader>z', ':ZenMode<CR>')
