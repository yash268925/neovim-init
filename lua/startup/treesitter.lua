local function is_treesitter_must_disable(bufnr)
  return vim.api.nvim_buf_line_count(bufnr) > 20000
end

local function setup()
  require('nvim-treesitter.configs').setup {
    ensure_installed = {
      'javascript', 'jsdoc', 'typescript', 'tsx',
      'bash', 'css', 'scss', 'rust',
      'lua', 'html', 'json', 'php',
      'phpdoc', 'java', 'make', 'markdown',
      'json5', 'jsonc', 'vim', 'toml',
      'vue', 'haskell', 'glsl'
    },
    highlight = {
      enable = true,
      disable = function (_, bufnr)
        return is_treesitter_must_disable(bufnr)
      end,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
      disable = {'vim'},
    },
  }
end

local filetype = {
  'bash', 'shell', 'html', 'markdown',
  'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'json', 'json5', 'jsonc', 'vue', 'glsl',
  'css', 'scss', 'rust', 'haskell', 'java', 'lua', 'make', 'vim', 'toml',
}

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    if not(vim.g['loaded_nvim-treesitter']) then
      vim.cmd.packadd('nvim-treesitter')
      setup()
    end
  end,
  pattern = filetype,
  once = true,
})

vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
