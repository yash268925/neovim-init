local M = {}

function M.on_attach(on_attach)
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local buf = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buf)
    end,
  })
end

function M.find_root(buf, pattern)
  local root = vim.g['project_root']
  if root then
    return root
  end
  pattern = pattern or { '.git' }
  local found = vim.fs.find(pattern, {
    upward = true,
    stop = vim.uv.os_homedir(),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(buf)),
  })[1]
  return vim.fs.dirname(found)
end

return M
