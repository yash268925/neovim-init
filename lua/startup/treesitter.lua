local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

parser_config.markdown = {
  install_info = {
    url = "https://github.com/ibash/tree-sitter-markdown.git",
    location = "tree-sitter-markdown",
    files = { "src/parser.c", "src/scanner.c" },
    revision = "ee0dac39fdbc8da1600756e5a19bf618cd79a47c",
  },
  maintainers = { "@MDeiml" },
  readme_name = "markdown (basic highlighting)",
  experimental = true,
}

parser_config.markdown_inline = {
  install_info = {
    url = "https://github.com/ibash/tree-sitter-markdown.git",
    location = "tree-sitter-markdown-inline",
    files = { "src/parser.c", "src/scanner.c" },
    revision = "ee0dac39fdbc8da1600756e5a19bf618cd79a47c",
  },
  maintainers = { "@MDeiml" },
  readme_name = "markdown_inline (needed for full highlighting)",
  experimental = true,
}

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
        local max_filesize = 100 * 1024 -- 100 KB
        local minified_max_filesize = 30 * 1024 -- 30 KB
        local minified_file_max_lines = 10
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats then
          if vim.api.nvim_buf_line_count(bufnr) < minified_file_max_lines and stats.size > minified_max_filesize then
            return true
          end
          if stats.size > max_filesize then
            return true
          end
        end
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
  'css', 'scss', 'rust', 'haskell', 'java', 'lua', 'make', 'vim', 'toml', 'php',
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
