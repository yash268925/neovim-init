local deck = require('deck')

deck.register_start_preset('buffers', function()
  deck.start({
    {
      name = 'buffers',
      execute = function(ctx)
        local current = vim.fn.expand('%:p'):gsub('/$', '')
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_get_option_value('buflisted', { buf = buf }) then
            local bufname = vim.api.nvim_buf_get_name(buf)
            if bufname ~= current then
              local filename = vim.fn.filereadable(bufname) == 1 and bufname
              ctx.item({
                display_text = filename and vim.fn.fnamemodify(filename, ':~') or bufname,
                data = { bufnr = buf, filename = filename },
              })
            end
          end
        end
        ctx.done()
      end,
      actions = {
        require('deck').alias_action('default', 'open'),
        require('deck').alias_action('write', 'write_buffer'),
      },
    },
  })
end)

vim.api.nvim_create_autocmd('User', {
  group = 'dotvim.picker',
  pattern = 'DeckStart:buffers',
  callback = function(e)
    local ctx = e.data.ctx --[[@as deck.Context]]

    ctx.keymap('n', 'd', deck.action_mapping('delete_buffer'))
    ctx.keymap('n', '<CR>', deck.action_mapping('open'))

    ctx.prompt()
  end
})
