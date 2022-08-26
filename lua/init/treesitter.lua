local ts_langs = {
  'javascript',
  'jsdoc',
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
  'phpdoc',
  'java',
  'make',
  'json5',
  'jsonc',
  'vim',
  'toml',
  'vue',
  'haskell',
  'glsl',
  'sql'
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
      'vim'
    }
  }
}
