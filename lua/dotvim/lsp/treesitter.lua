local languages = {
  'css', 'html', 'javascript', 'lua',
  'markdown', 'php', 'tsx', 'typescript', 'vim',
  'xml'
}

---@param opts { indent: boolean }
return function(opts)
  require('nvim-treesitter').install(languages)

  local enabled = {}
  for _, lang in ipairs(languages) do
    enabled[lang] = true
  end

  -- filetype の別名 (typescriptreact → tsx など) は nvim-treesitter の plugin/ が
  -- この setup より後に登録するため、pattern を事前に列挙できない
  vim.api.nvim_create_autocmd('FileType', {
    group = 'dotvim.lsp',
    callback = function(args)
      local lang = vim.treesitter.language.get_lang(args.match)
      if not lang or not enabled[lang] then
        return
      end
      -- install は非同期なので、初回起動時はまだパーサが無いことがある
      if not vim.treesitter.language.add(lang) then
        return
      end

      vim.treesitter.start(args.buf, lang)
      if opts.indent then
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  })
end
