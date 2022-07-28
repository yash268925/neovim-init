local ts_langs = {
  'javascript',
  'typescript',
  'tsx',
  'bash',
  'css',
  'scss',
  'rust',
  'markdown',
  'lua',
  'html',
  'json',
  'php',
  'java',
  'make',
  'json5',
  'vim',
  'toml',
  'vue',
  'haskell',
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = ts_langs,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    disable = {
      'vim',
    }
  }
}
