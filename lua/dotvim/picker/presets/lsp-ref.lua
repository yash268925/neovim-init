local deck = require('deck')

deck.register_start_preset({
  name = 'lsp-ref',
  start = function()
    deck.start({
      name = 'lsp-ref',
      execute = function(ctx)
        local bufnr = ctx.get_prev_buf()
        local win = ctx.get_prev_win()
        local cursor = vim.api.nvim_win_get_cursor(win)

        local params = {
          textDocument = { uri = vim.uri_from_bufnr(bufnr) },
          position = { line = cursor[1] - 1, character = cursor[2] },
          context = { includeDeclaration = true },
        }

        local cancel = vim.lsp.buf_request_all(bufnr, 'textDocument/references', params, function(results)
          if ctx.aborted() then return end

          for _, result in pairs(results) do
            for _, location in ipairs(result.result or {}) do
              local filename = vim.uri_to_fname(location.uri)
              local lnum = location.range.start.line + 1
              local col_num = location.range.start.character + 1

              local line_text = ''
              local buf = vim.fn.bufnr(filename)
              if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
                local lines = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)
                line_text = (lines[1] or ''):gsub('^%s+', '')
              else
                local ok, lines = pcall(vim.fn.readfile, filename)
                if ok and lines[lnum] then
                  line_text = lines[lnum]:gsub('^%s+', '')
                end
              end

              ctx.item({
                display_text = {
                  { ('%s:%s:%s '):format(vim.fn.fnamemodify(filename, ':~:.'), lnum, col_num) },
                  { line_text, 'Comment' },
                },
                data = {
                  filename = filename,
                  lnum = lnum,
                  col = col_num,
                },
              })
            end
          end

          ctx.done()
        end)

        if type(cancel) == 'function' then
          ctx.on_abort(cancel)
        end
      end,
      actions = {
        require('deck').alias_action('default', 'open'),
      },
    })
  end,
})
