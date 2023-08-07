local util = require('lsp')

local function buf_cache(bufnr, client)
  local params = {}
  params['referrer'] = { uri = vim.uri_from_bufnr(bufnr) }
  params['uris'] = {}
  client.request('deno/cache', params, function(err, _result, ctx)
    if err then
      local uri = ctx.params.referrer.uri
      vim.api.nvim_err_writeln('cache command failed for ' .. vim.uri_to_fname(uri))
    end
  end, bufnr)
end

local function virtual_text_document_handler(uri, res, client)
  if not res then
    return nil
  end

  local lines = vim.split(res.result, '\n')
  local bufnr = vim.uri_to_bufnr(uri)

  local current_buf = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #current_buf ~= 0 then
    return nil
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, 'readonly', true)
  vim.api.nvim_buf_set_option(bufnr, 'modified', false)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  vim.lsp.buf_attach_client(bufnr, client.id)
end

local function virtual_text_document(uri, client)
  local params = {
    textDocument = {
      uri = uri,
    },
  }
  local result = client.request_sync('deno/virtualTextDocument', params)
  virtual_text_document_handler(uri, result, client)
end

local function denols_handler(err, result, ctx, config)
  if not result or vim.tbl_isempty(result) then
    return nil
  end

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  for _, res in pairs(result) do
    local uri = res.uri or res.targetUri
    if uri:match '^deno:' then
      virtual_text_document(uri, client)
      res['uri'] = uri
      res['targetUri'] = uri
    end
  end

  vim.lsp.handlers[ctx.method](err, result, ctx, config)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'javascript', 'javascriptreact', 'typescript', 'typescriptreact'},
  callback = function(ev)
    local buf = ev.buf
    local deno_root = util.find_root(buf, { 'deno.json', 'deno.jsonc' })
    local node_root = util.find_root(buf, { 'package.json', '.git' })
    local client
    if deno_root then
      client = vim.lsp.start({
        name = 'denols',
        cmd = { 'deno', 'lsp' },
        cmd_env = { NO_COLOR = true },
        init_options = {
          enable = true,
          unstable = true,
        },
        root_dir = deno_root,
        handlers = {
          ['textDocument/definition'] = denols_handler,
          ['textDocument/typeDefinition'] = denols_handler,
          ['textDocument/references'] = denols_handler,
          ['workspace/executeCommand'] = function(err, result, context, config)
            if context.params.command == 'deno.cache' then
              buf_cache(context.bufnr, vim.lsp.get_client_by_id(context.client_id))
            else
              vim.lsp.handlers[context.method](err, result, context, config)
            end
          end,
        },
      })
    else
      client = vim.lsp.start({
        name = 'tsserver',
        cmd = { 'typescript-language-server', '--stdio' },
        init_options = { hostInfo = 'neovim' },
        root_dir = node_root,
        single_file_support = true,
      })
    end
    vim.lsp.buf_attach_client(buf, client)
  end,
})

vim.g.markdown_fenced_languages = {
  "ts=typescript",
  "js=javascript",
}
