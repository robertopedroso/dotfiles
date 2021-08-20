require('nvim-treesitter.configs').setup {
   ensure_installed = {
      "bash",
      "lua",
      "python",
      "javascript",
   },
   highlight = {
      enable = true,
      use_languagetree = true,
   },
}
