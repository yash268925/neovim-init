local langs = {
  'javascript',
  'jsdoc',
  'typescript',
  'tsx',
  'bash',
  'css',
  'scss',
  'rust',
  'lua',
  'html',
  'json',
  'php',
  'phpdoc',
  'java',
  'make',
  'markdown',
  'json5',
  'jsonc',
  'vim',
  'toml',
  'vue',
  'haskell',
  'glsl'
}

local function ts_disable(bufnr)
  return vim.api.nvim_buf_line_count(bufnr) > 2000
end

require'nvim-treesitter.configs'.setup {
  ensure_installed = langs,
  highlight = {
    enable = true,
    disable = function (_, bufnr)
      return ts_disable(bufnr)
    end,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    disable = {
      'vim'
    }
  }
}
